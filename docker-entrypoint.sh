#!/bin/bash

set -e

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
        set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`

if [ "$1" = 'elasticsearch' ]; then
        # Change the ownership of /usr/share/elasticsearch/data to elasticsearch
        chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data
        
        # if the setup flag and variable is set, just startup the normal elasticsearch, otherwise to the setup
        if [ ! ${SETUP+x} ] || ([ ${SETUP+x} ] && [ -e /SETUP_FLAG ] && [ $(cat /SETUP_FLAG) = "true" ])
        then
            if [ "$(id -u)" = '0' ]
            then
                set -- gosu elasticsearch "$@"
                #exec gosu elasticsearch "$BASH_SOURCE" "$@"
            fi
        else
            # unset the command and start setup
            unset $@
            set "echo Setup Done" "$@"

            echo Start Setup
            gosu elasticsearch elasticsearch &
            sleep 15 && curl -XPOST "localhost:9200/wikiviews" --retry 10 --retry-delay 5 --data-binary /usr/share/elasticsearch/setup/wikiviews.index.json && echo 'true' > /SETUP_FLAG
        fi
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
