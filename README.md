# Shared Data Infrastructure

This repository owns shared local infrastructure for `data-benchmark`, `flink-data-balance`, and `data-gov`.

## Profiles

- `lakehouse`: HDFS, Hive Metastore.
- `lakehouse-tools`: HiveServer2.
- `yarn`: ResourceManager and NodeManager.
- `spark-tools`: Spark SQL tools.
- `streaming`: ZooKeeper-backed Kafka.
- `starrocks`: Shared all-in-one StarRocks.
- `observability`: Optional shared observability tools.

## Network

All shared services are attached to Docker network `shared-data-infra`.

Project compose files should connect app containers to this external network and use environment variables for endpoints.

## Lakehouse

The lakehouse overlay provides HDFS at `hdfs://namenode:8020`, Hive Metastore at `thrift://hive-metastore:9083`, optional HiveServer2, optional YARN, and an interactive Spark SQL tool container.

Validate the core lakehouse profile:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse config
```

Validate lakehouse with YARN and Spark tools:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile yarn --profile spark-tools config
```

Start the core lakehouse services:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse up -d
```

Start lakehouse plus YARN:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile yarn up -d
```

Run Spark SQL after the lakehouse profile is healthy:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile spark-tools run --rm spark
```

HiveServer2 is available under the `lakehouse-tools` profile:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile lakehouse-tools up -d hive-server
```

Ports can be overridden with environment variables from `env/ports.env`, including `HIVE_METASTORE_PORT`, `HIVE_SERVER_PORT`, `HDFS_NAMENODE_HTTP_PORT`, `HDFS_NAMENODE_RPC_PORT`, `HDFS_DATANODE_HTTP_PORT`, `HMS_DB_PORT`, `YARN_RM_PORT`, `YARN_RM_RPC_PORT`, and `YARN_NM_PORT`.

The overlay vendors `docker/jars/postgresql-42.7.3.jar` and mounts it into Hive Metastore at `/opt/hive/lib/postgresql-42.7.3.jar`, because `apache/hive:4.0.0` does not include a PostgreSQL JDBC driver by default.

## Streaming

The streaming overlay provides ZooKeeper-backed Kafka for initial `flink-data-balance` migration compatibility. Shared app containers should use `kafka:9092` as the internal Kafka bootstrap endpoint. During `flink-data-balance` migration, replace the project-local bootstrap `kafka:29092` with the shared endpoint `kafka:9092`. Host clients can use `localhost:${KAFKA_EXTERNAL_PORT:-19092}`.

Validate the streaming profile:

```bash
docker compose -f compose.yaml -f compose.streaming.yaml --profile streaming config
```

Start the streaming services:

```bash
docker compose -f compose.yaml -f compose.streaming.yaml --profile streaming up -d
```

Kafka UI is available under the `observability` profile:

```bash
docker compose -f compose.yaml -f compose.streaming.yaml --profile streaming --profile observability up -d kafka-ui
```

## StarRocks

The StarRocks overlay provides a shared all-in-one StarRocks service for local development. The all-in-one image is treated as stateless shared dev infrastructure here because this repo does not yet pin a confirmed durable data directory for `starrocks/allin1-ubuntu:3.2-latest`.

Validate the StarRocks profile:

```bash
docker compose -f compose.yaml -f compose.starrocks.yaml --profile starrocks config
```

Start StarRocks:

```bash
docker compose -f compose.yaml -f compose.starrocks.yaml --profile starrocks up -d
```

Ports can be overridden with `STARROCKS_HTTP_PORT`, `STARROCKS_MYSQL_PORT`, and `STARROCKS_BE_PORT`.
