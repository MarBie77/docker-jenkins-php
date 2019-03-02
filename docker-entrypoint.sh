#!/bin/sh
set -e
set -x

# update global dependencies
composer global config minimum-stability dev
composer global config prefer-stable true
composer global require --no-interaction --no-progress --no-suggest phpunit/phpunit:^7.0 squizlabs/php_codesniffer phploc/phploc pdepend/pdepend phpmd/phpmd sebastian/phpcpd mayflower/php-codebrowser theseer/phpdox:dev-master

if [ ! -e $JENKINS_HOME/jobs/php-template/config.xml ]
then
    # install default php build template
    mkdir -p $JENKINS_HOME/jobs/php-template
    cp /usr/src/docker-jenkins-php/config.xml $JENKINS_HOME/jobs/php-template
fi

exec /usr/local/bin/jenkins.sh "$@"
