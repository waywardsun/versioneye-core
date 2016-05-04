# versioneye-core

This project contains the core elements of VersionEye.

 - Models & Persistence
 - Services
 - Mailers
 - Parsers
 - RabbitMQ Producers & Workers

This project is used as a dependency in all other VersionEye Ruby projects!

This project is setup and managed with [jeweler](https://www.versioneye.com/ruby/jeweler).

## Tests

The tests for this project are running after each `git push` on [CircleCI](https://circleci.com/gh/versioneye/versioneye-core)!
First of all a Docker image is build for this project and the tests are executed in a Docker container.
For more details take a look to the Dockerfile and the circle.yml file in the root directory!

If the Docker containers for the backend systems are running locally, the tests can be executed locally
with this command:

```
./scripts/runtests_local.sh
```

For that the ENV variables in the `runtests_local.sh` script need to be adjusted that way, that they point
to the backend systems.


## License

VersionEye-Core is licensed under the MIT license!

Copyright (c) 2016 VersionEye GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
