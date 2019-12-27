#!/bin/sh
set -e
set -x

# update global dependencies
composer global update

if [ ! -e $JENKINS_HOME/jobs/php-template/config.xml ]
then
    # install default php build template
    mkdir -p $JENKINS_HOME/jobs/php-template
    cp /usr/src/docker-jenkins-php/config.xml $JENKINS_HOME/jobs/php-template
fi

exec /usr/local/bin/jenkins.sh "$@"
