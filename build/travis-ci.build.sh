#!/usr/bin/env bash

COMMIT=$(echo $TRAVIS_COMMIT | cut -b1-7)
echo $TRAVIS_COMMIT
echo $COMMIT
echo $TRAVIS_TAG

if [ ${TRAVIS_TAG+x} ]
then
  docker build -f Dockerfile -t "$REPO:$TRAVIS_TAG" -t "$REPO:latest" .
else
  docker build -f Dockerfile -t "$REPO:$COMMIT" .
fi
