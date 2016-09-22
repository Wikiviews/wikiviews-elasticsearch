#!/usr/bin/env bash

COMMIT=${TRAVIS_COMMIT::8}

if [ ${TRAVIS_TAG+x} ]
then
  docker build -f Dockerfile -t "$REPO:$TRAVIS_TAG" -t "$REPO:latest" .
else
  docker build -f Dockerfile -t "$REPO:$COMMIT" .
fi