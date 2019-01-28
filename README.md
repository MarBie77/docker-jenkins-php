# docker-jenkins-php
Docker container for Jenkins to build PHP Applications

## Setup Jenkins

### First time installation
1. Use the initial Password in the container logs to setup Jenkins.
2. Create a new build project with using the "php-template" project
3. Do NOT forget to add the build-files to your GIT-repository, which you want to build

### Jenkins Settings
Goto "Manage Jenkins" und choose "Configure System", then change:

* Environment Variables
  * Name: PATH+EXTRA
  * Value: vendor/bin:/var/jenkins_home/.composer/vendor/bin/

This makes sure, that your local composer.json tool versions are used before the global ones.

> Do NOT modify the PATH-environment, otherwise the sh-command will fail when used with pipeline projects!

### docker-compose.yml example configuration
Mount the volume /var/jenkins_home, so data is not lost during update.

```yaml
version: '3'

volumes:
  jenkins-data:

services:
  jenkins:
    container_name: jenkins
    image: marbie77/docker-jenkins-php:latest
    volumes:
       - jenkins-data:/var/jenkins_home
    networks:
      app_net:
        ipv4_address: 172.29.0.140

networks:
  app_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.29.0.0/16
```

### Nginx configuration example
example configuration for ssl Jenkins. Certificates need to be fetched from https://letsencrypt.org/

```Nginx
server {
    listen 443 ssl http2;
    server_name jenkins.example.com;

    ssl_certificate "/etc/letsencrypt/live/jenkins.example.com/fullchain.pem";
    ssl_certificate_key "/etc/letsencrypt/live/jenkins.example.com/privkey.pem";
    
    ssl_dhparam /etc/nginx/ssl/dhparams.pem;
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout  10m;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header        Host $host:$server_port;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_set_header	X-Forwarded-Host $host:$server_port;

        proxy_redirect http:// https://;
    	proxy_pass              http://jenkins:8080;

        # Required for new HTTP-based CLI
        proxy_http_version 1.1;
        proxy_request_buffering off;
        proxy_buffering off; # Required for HTTP-based CLI to work over SSL
        # workaround for https://issues.jenkins-ci.org/browse/JENKINS-45651
        add_header 'X-SSH-Endpoint' 'jenkins.example.com:50022' always;
    }
}
```

To generate dhparams.pem (Diffie Hellman Parameters, see https://security.stackexchange.com/questions/95178/diffie-hellman-parameters-still-calculating-after-24-hours/95184#95184), use
```bash
openssl dhparam -dsaparam -out /etc/ssl/private/dhparam.pem 4096
```

### Test your SSL/HTTPS installation
SSL-Tester: https://www.ssllabs.com/ssltest/

### Backup Jenkins
Do NOT forget to backup the jenkins-data volume!

## Notice
The container image installs the php-dependencies for the jenkins plugin on first run. If you want to update them to new versions:

Connect to container (i.e. "docker-compose exec jenkins bash"):
```bash
cd /var/jenkins_home/.composer
composer update
```
