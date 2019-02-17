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
RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# switch back to jenkins user
USER jenkins

# install jenkins plugis
RUN install-plugins.sh ant cloverphp crap4j htmlpublisher plot xunit git greenballs warnings-ng workflow-aggregator clover

# add entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh" ]
