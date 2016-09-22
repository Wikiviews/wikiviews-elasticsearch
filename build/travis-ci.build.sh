#!/usr/bin/env bash

COMMIT=$(echo $TRAVIS_COMMIT | cut -b1-7)

if [ $TRAVIS_TAG ]
then
  docker build -f Dockerfile -t "$REPO:$TRAVIS_TAG" -t "$REPO:latest" .
else
  docker build -f Dockerfile -t "$REPO:$COMMIT" .
fi
