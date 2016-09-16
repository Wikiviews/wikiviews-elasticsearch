# Wikiviews Elasticsearch
The setup of the Wikiviews [Elasticsearch](https://www.elastic.co/products/elasticsearch) backend.

Elasticsearch fullfills the purpose of storing and indexing large ammounts of data, to make them accessible, searchable and
analyzable.

Wikiviews uses Elasticsearch for storing the pageview data, index them to make them full-text searchable and sortable and perform
queries on the data.

## Elasticsearch structure
Wikiviews uses the following elasticsearch structure:

One index (by default `wikiviews`) with one type (by default `article`). The `wikiviews` index has the following mapping:
```json
{
    "settings": {
        "number_of_shards": 10,
        "number_of_replicas": 0
      },
    "mappings": {
        "article": {
            "properties": {
                "article": { "type": "string" },
                "exact_article": {
                    "type":  "string",
                    "index": "not_analyzed"
                },
                "views": {
                    "type": "nested",
                    "properties": {
                        "date": { "type": "date", "format": "strict_date_time" },
                        "views": { "type": "long" }
                    }
                }
            }
        }
    }
}
```

By default it is set up with 10 shards and 0 replica shards. If you want to use other settings, adapt the
`setup/articles.index.json` file and rebuild the Docker image.

The `article` type contains the article name in the `article.article` property and a unindexed copy of the name in the
`article.exact_article` property for actions like range filtering and sorting. The dates with their corresponding view counts are
stored in the `article.views` list, whose sub-objects are set as nested-objects to preserve their relatedness for queries on the
date-views pairs.

This configuration  provides the `add-date` script, for inserting a date-views pair into an existing article. The script needs to be
executed in an article insert context (e.g. an upsert context) and is parameterized with the parameter `new_date`. The `new_date`
parameter demands the following structure:
```json
{
    "date": { "type": "date", "format": "strict_date_time" },
    "views": { "type": "long" }
}
```

The implicit creation of indices and mappings is disables in this configuration to achieve more safety in the defined and used types. Thereby it is necessary to create the indices and mappings via the [indices API of Elasticsearch](<!-- TODO -->).

The provided cluster name is `wikiviews-es-cluster`.

## Building & Setup
This repository provides a setup for a Docker container, which also provides the ability to initialize the Elasticsearch cluster
with the default index and mapping. It is also possible to [manually configure the cluster](#manual-building).

### Building and running with Docker
To build the Docker image for the Wikiviews Elasticsearch cluster, run:
```shell
docker build -t {TAG-NAME} .
```

To run an instance with setup, run
```shell
docker run -e "SETUP=true" --name {CONTAINER-NAME} -p 9200:9200 {TAG-NAME}
```
After the process ended, restart the docker container with
```shell
docker restart {CONTAINER-NAME}
```
The cluster is now up and running.

To run an instance without setup (e.g. for scaling the cluster up, if another instance is already running), run
```shell
docker run -d -p 9200:9200 {TAG-NAME}
```

It is recommended to use a [datavolume](<!-- TODO -->) for the path `/usr/share/elasticsearch/data` to keep your Elasticsearch
data, even when you remove the according containers.

### Manual Building
It is also possible to run this Elasticsearch configuration without Docker. 

To achieve that, copy the file `config/elasticsearch.yml` to your Elasticsearch configuration directory (usually
`/usr/share/elasticsearch/config`) and `scripts/add-date.groovy` to the scripts directory (usually
`/usr/share/elasticsearch/config/scripts`). Set the environment variable `ES_HEAP_SIZE` to at least `3g` and start Elasticsearch
(`elasticsearch`). After that, initialize the Cluster with the index and mapping (e.g. via curl):
```shell
curl -XPOST "{ELASTICSEARCH-ADDRESS}:9200/wikiviews" --data-binary setup/wikiviews.index.json 
```

