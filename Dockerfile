FROM jenkins/jenkins:lts-alpine
LABEL maintainer="Martin Biermair <martin@biermair.at>"

# switch to root user to install additional packages
USER root

# install alpine packages executable ant for jenkins
RUN apk add --no-cache yarn apache-ant rsync

# adding php with extensions
RUN apk add --no-cache php7@edge php7-dom@edge php7-xml@edge php7-xmlwriter@edge php7-openssl@edge php7-json@edge php7-phar@edge php7-iconv@edge php7-mbstring@edge php7-tokenizer@edge php7-simplexml@edge php7-xsl@edge php7-fileinfo@edge php7-soap@edge php7-xdebug@edge php7-pdo@edge php7-intl@edge php7-session@edge

# copy php configuration files
COPY ./php-conf.d/*.ini /etc/php7/conf.d/

COPY ./config.xml /usr/src/docker-jenkins-php/

# workaround for iconv-problem in phpdox (//TRANSLIT is not supported charset in alpine)
# see also https://github.com/docker-library/php/issues/240
# see https://wiki.musl-libc.org/functional-differences-from-glibc.html#iconv
RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# install composer
RUN apk add --no-cache composer

# switch back to jenkins user
USER jenkins

# install jenkins plugis
RUN install-plugins.sh ant cloverphp crap4j htmlpublisher plot xunit git greenballs warnings-ng workflow-aggregator clover

# copy composer.json to global home of jenkins user
COPY ./addon/composer.json ${JENKINS_HOME}/.composer/

# add entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh" ]
