# Shared Data Infrastructure

This repository owns shared local infrastructure for `data-benchmark`, `flink-data-balance`, and `data-gov`.

## Profiles

- `lakehouse`: HDFS, Hive Metastore.
- `lakehouse-tools`: HiveServer2.
- `yarn`: ResourceManager and NodeManager.
- `spark-tools`: Spark SQL tools.
- `streaming`: Kafka and ZooKeeper/KRaft, added by the streaming overlay.
- `starrocks`: StarRocks, added by the StarRocks overlay.
- `observability`: Prometheus, Grafana, Kafka UI, added by the observability overlay.

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
