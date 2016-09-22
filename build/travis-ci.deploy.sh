#!/usr/bin/env bash

if [ $TRAVIS_TAG ]
then
    echo "Deploy to Docker Hub: $REPO"
    docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
    docker push $REPO
else
    echo "Skip deployment do Docker Hub because it is not a tagged commit"
fi