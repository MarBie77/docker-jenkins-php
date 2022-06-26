FROM jenkins/jenkins:lts-alpine
LABEL maintainer="Martin Biermair <martin@biermair.at>"

# switch to root user to install additional packages
USER root

# install alpine packages executable ant for jenkins
RUN apk add --no-cache npm apache-ant rsync

# adding php with extensions
RUN apk add --no-cache php81 php81-dom php81-curl php81-xml php81-xmlwriter php81-openssl php81-json php81-phar php81-iconv php81-mbstring php81-tokenizer php81-simplexml php81-xsl php81-fileinfo php81-soap php81-xdebug php81-pdo php81-intl php81-session

# add php8 as default binary
RUN ln -s /usr/bin/php81 /usr/bin/php

# install corepack because nodejs < 16.10, needed for yarn 3.x
RUN npm -g install corepack

# install latest yarn
RUN yarn set version stable

# copy php configuration files
COPY ./php-conf.d/*.ini /etc/php8/conf.d/

COPY ./config.xml /usr/src/docker-jenkins-php/

# workaround for iconv-problem in phpdox (//TRANSLIT is not supported charset in alpine)
# see also https://github.com/docker-library/php/issues/240
# see https://wiki.musl-libc.org/functional-differences-from-glibc.html#iconv
#RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
#ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# install composer from composer docker image
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# switch back to jenkins user
USER jenkins

# install jenkins plugis
RUN jenkins-plugin-cli --plugins ant crap4j htmlpublisher plot xunit git greenballs warnings-ng workflow-aggregator clover

# copy composer.json to global home of jenkins user
COPY --chown=jenkins:jenkins ./addon/composer.json ${JENKINS_HOME}/.composer/

# add entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh" ]
