FROM elasticsearch:2.3

MAINTAINER DevWurm <devwurm@devwurm.net>

COPY ./config /usr/share/elasticsearch/config
COPY ./scripts /usr/share/elasticsearch/config/scripts
COPY ./setup /usr/share/elasticsearch/setup
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENV ES_HEAP_SIZE=4g

EXPOSE 9200 9300

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]
