require 'benchmark'
require 'dalli'

class BitbucketService < Versioneye::Service

  A_TASK_NIL     = nil
  A_TASK_RUNNING = 'running'
  A_TASK_DONE    = 'done'
  A_TASK_TTL     = 600 # 600 seconds = 10 minutes


  def self.update_repo_info(user, repo_fullname)
    current_repo = user.bitbucket_repos.where(fullname: repo_fullname).shift
    if current_repo.nil?
      log.error "User #{user[:username]} has no such repo `#{repo_fullname}`"
      return nil
    end

    token  = user[:bitbucket_token]
    secret = user[:bitbucket_secret]

    repo = Bitbucket.update_branches      current_repo, token, secret
    repo = Bitbucket.update_project_files current_repo, token, secret
    repo.save
    repo
  end


  def self.cached_user_repos user
    user_task_key = "#{user[:username]}-bitbucket"
    task_status = cache.get(user_task_key)

    if task_status == A_TASK_RUNNING || task_status == A_TASK_DONE
      log.debug "Status for importing repos for #{user[:username]} from bitbucket => #{task_status}"
      return task_status
    end

    if user[:bitbucket_token] and user.bitbucket_repos.all.count == 0
      task_status =  A_TASK_RUNNING
      cache.set( user_task_key, task_status, A_TASK_TTL )
      GitReposImportProducer.new("bitbucket:::#{user.id.to_s}")
    else
      log.info "Nothing to import - maybe clean user's repo?"
      task_status = A_TASK_DONE
    end

    task_status
  end


  def self.status_for user, current_repo
    return A_TASK_DONE if current_repo.nil?

    repo_task_key = "bitbucket:::#{user.id.to_s}:::#{current_repo.id.to_s}"
    task_status   = cache.get( repo_task_key )
    if task_status == A_TASK_RUNNING || task_status == A_TASK_DONE
      repo_fullname = current_repo.fullname
      log.debug "Status for importing branches and project files from `#{repo_fullname}.`: #{task_status}"
      return task_status
    end

    if current_repo and ( current_repo.branches.nil? || current_repo.branches.empty? )
      GitRepoImportProducer.new( repo_task_key )
      task_status = A_TASK_RUNNING
      cache.set( repo_task_key, task_status, A_TASK_TTL )
    else
      log.info 'Nothing is changed - skipping update.'
      task_status = A_TASK_DONE
    end

    task_status
  end


  def self.cache_user_all_repos(user)
    return nil if user.nil?

    log.info "Going to cache user repositories for #{user.username}"

    cache_repos( user, user[:bitbucket_id] )

    user_orgs = Bitbucket.user_orgs(user)
    if !user_orgs.nil? && !user_orgs.empty?
      user_orgs.each do |org|
        self.cache_repos( user, org )
      end
    end

    # Import missing invited repos
    cache_invited_repos(user)
  end


  def self.cache_repos(user, owner_name)
    token  = user[:bitbucket_token]
    secret = user[:bitbucket_secret]
    repos  = Bitbucket.read_repos(owner_name, token, secret)
    persist user, repos
    return true
  end


  def self.cache_invited_repos( user )
    token  = user[:bitbucket_token]
    secret = user[:bitbucket_secret]
    repos  = Bitbucket.read_repos_v1( token, secret )
    if repos.nil? or repos.empty?
      log.error "cache_invited_repos | didnt get any repos from APIv1."
      return false
    end

    user.reload
    existing_repo_fullnames  = Set.new user.bitbucket_repos.map(&:fullname)
    missing_repos = repos.keep_if {|repo| existing_repo_fullnames.include?(repo[:full_name]) == false}
    invited_repos = missing_repos.delete_if do |repo|
      # Remove other people forks
      repo.has_key?(:fork_of) and repo[:fork_of].is_a?(Hash) and repo[:fork_of][:owner] == user[:bitbucket_id]
    end

    # Add missing repos
    searched_repos = []
    invited_repos.each do |old_repo|
      repo = Bitbucket.repo_info(old_repo[:full_name], token, secret) #fetch repo info from api2
      if repo.nil?
        log.error "cache_invited_repos | didnt get repo info for `#{old_repo[:full_name]}`"
        next
      end
      searched_repos << repo
    end
    persist user, searched_repos
    true
  end


  def self.persist user, repos
    return false if repos.nil? || repos.empty?

    repos.each do |repo|
      BitbucketRepo.build_or_update user, repo
    end
  end


end
