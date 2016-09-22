#!/usr/bin/env bash

COMMIT=$(echo $TRAVIS_COMMIT | cut -b1-7)

if [ $TRAVIS_TAG ]
then
  TAG=$(echo $TRAVIS_TAG | sed 's/v//g')
  docker build -f Dockerfile -t "$REPO:$TAG" -t "$REPO:latest" .
else
  docker build -f Dockerfile -t "$REPO:$COMMIT" .
fi
