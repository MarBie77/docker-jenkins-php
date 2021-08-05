FROM jenkins/jenkins:lts-alpine
LABEL maintainer="Martin Biermair <martin@biermair.at>"

# switch to root user to install additional packages
USER root

# install alpine packages executable ant for jenkins
RUN apk add --no-cache yarn apache-ant rsync

# adding php with extensions
RUN apk add --no-cache php7 php7-dom php7-xml php7-xmlwriter php7-openssl php7-json php7-phar php7-iconv php7-mbstring php7-tokenizer php7-simplexml php7-xsl php7-fileinfo php7-soap php7-xdebug php7-pdo php7-intl php7-session

# copy php configuration files
COPY ./php-conf.d/*.ini /etc/php7/conf.d/

COPY ./config.xml /usr/src/docker-jenkins-php/

# workaround for iconv-problem in phpdox (//TRANSLIT is not supported charset in alpine)
# see also https://github.com/docker-library/php/issues/240
# see https://wiki.musl-libc.org/functional-differences-from-glibc.html#iconv
#RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
#ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# install composer
RUN apk add --no-cache composer

# switch back to jenkins user
USER jenkins

# install jenkins plugis
RUN install-plugins.sh ant crap4j htmlpublisher plot xunit git greenballs warnings-ng workflow-aggregator clover

# copy composer.json to global home of jenkins user
COPY --chown=jenkins:jenkins ./addon/composer.json ${JENKINS_HOME}/.composer/

# add entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh" ]
