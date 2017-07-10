FROM        ruby:2.4.1-slim
MAINTAINER  Robert Reiz <reiz@versioneye.com>

ENV RAILS_ENV enterprise
ENV BUNDLE_GEMFILE /app/Gemfile
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

# libfontconfig1 is mandatory for PDFKit

RUN apt-get update; \
    apt-get install -y libfontconfig1; \
    apt-get install -y git; \
    apt-get install -y build-essential; \
    apt-get install -y supervisor; \
    gem uninstall -i /usr/local/lib/ruby/gems/2.4.0 bundler -a -x; \
    gem install bundler --version 1.15.1; \
    rm -Rf /app; mkdir -p /app; mkdir -p /app/log; mkdir -p /app/pids

ADD . /app/

WORKDIR /app

RUN bundle update
