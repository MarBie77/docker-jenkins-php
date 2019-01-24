# docker-jenkins-php
Docker container for Jenkins to build PHP Applications

## Warnings
The container image installs the php-dependencies for the jenkins plugin on first run. If you want to update them to new versions:

Connect to container (i.e. "docker-compose exec jenkins bash"):
```bash
cd /var/jenkins_home/.composer
composer update
```

## Usage
1. Use the initial Password in the container logs to setup Jenkins.
2. Create a new build project with using the "php-template" project
3. Do NOT forget to add the build-files to your GIT-repository, which you want to build