#!/bin/sh
set -e
set -x

# removing old composer installation
rm -f $JENKINS_HOME/.composer

# update global dependencies
composer global config minimum-stability dev
composer global config prefer-stable true
composer global require --no-interaction --no-progress --no-suggest phpunit/phpunit squizlabs/php_codesniffer phploc/phploc pdepend/pdepend phpmd/phpmd sebastian/phpcpd mayflower/php-codebrowser theseer/phpdox:dev-master

# TODO: change to an own composer.json file!

if [ ! -e $JENKINS_HOME/jobs/php-template/config.xml ]
then
    # install default php build template
    mkdir -p $JENKINS_HOME/jobs/php-template
    cp /usr/src/docker-jenkins-php/config.xml $JENKINS_HOME/jobs/php-template
fi

exec /usr/local/bin/jenkins.sh "$@"
