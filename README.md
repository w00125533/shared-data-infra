# Shared Data Infrastructure

This repository owns shared local infrastructure for `data-benchmark`, `flink-data-balance`, and `data-gov`.

## Profiles

- `lakehouse`: HDFS, Hive Metastore, and HDFS warehouse initialization.
- `lakehouse-tools`: Long-running HiveServer2 for Beeline/JDBC clients.
- `yarn`: ResourceManager and NodeManager.
- `spark-tools`: Long-running Spark SQL tool service.
- `streaming`: ZooKeeper-backed Kafka.
- `starrocks`: Split StarRocks FE/BE services.
- `data-gov`: Neo4j graph store for the data-gov app.
- `observability`: Optional shared observability tools.

## Network

All shared services are attached to Docker network `shared-data-infra`.

Project compose files should connect app containers to this external network and use environment variables for endpoints.

## Helper Scripts

Start the core lakehouse services:

```sh
sh scripts/infra-up.sh lakehouse
```

Start lakehouse plus streaming services:

```sh
sh scripts/infra-up.sh lakehouse,streaming
```

Show shared infrastructure status:

```sh
sh scripts/infra-status.sh
```

Stop shared infrastructure:

```sh
sh scripts/infra-down.sh
```

## Benchmark-Compatible Startup

Start the full shared stack used by `data-benchmark` compose runs:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml -f compose.starrocks.yaml --profile lakehouse --profile lakehouse-tools --profile spark-tools --profile starrocks up -d
```

## Lakehouse

The lakehouse overlay provides HDFS, Hive Metastore, HDFS warehouse initialization, optional HiveServer2, optional YARN, and a long-running Spark SQL tool container.

Cross-project clients on the `shared-data-infra` network should use these internal endpoints:

| Service | Endpoint |
| --- | --- |
| HDFS | `hdfs://hdfs-namenode:8020` |
| Hive Metastore | `thrift://hive-metastore:9083` |
| HiveServer2 | `jdbc:hive2://hive-server:10000/default` |

The `lakehouse` profile includes `hdfs-init`, which creates the shared HDFS roots used by local services:

| Path | Purpose |
| --- | --- |
| `/warehouse/iceberg` | Hive Metastore / Iceberg table warehouse. Managed tables belong here, not raw generated data. |
| `/services/<service-or-project>/<data-type>` | Service-owned data root. The second path segment is the service or project name; the third segment is the data type. |

`data-benchmark` writes generated HDFS parquet under `/services/data-benchmark/generated/...`. The shared layout intentionally avoids a generic `/data` root and no longer creates a top-level `/benchmark` root.

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

Start lakehouse plus HiveServer2 and Spark tools for benchmark-compatible clients:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile lakehouse-tools --profile spark-tools up -d
```

Run Spark SQL after the `spark` service is healthy. The Spark tool service is long-running; use `docker compose exec` instead of one-shot `run` commands so clients share the same service lifecycle:

```bash
docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile spark-tools exec spark /opt/spark/bin/spark-sql --master local[*]
```

HiveServer2 is available under the `lakehouse-tools` profile for Beeline and JDBC clients at `jdbc:hive2://hive-server:10000/default`.

The Spark service mounts the benchmark workspace at `/workspace`. `BENCHMARK_WORKSPACE` defaults to `../data-benchmark`; override it when this repository and the benchmark repository are checked out in a different relative layout:

```bash
BENCHMARK_WORKSPACE=/absolute/path/to/data-benchmark docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile spark-tools up -d spark
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

The StarRocks overlay provides split FE/BE services for benchmark and local development workloads.

Cross-project clients on the `shared-data-infra` network should use these internal endpoints:

| Service | Endpoint |
| --- | --- |
| StarRocks FE HTTP | `http://starrocks-fe:8030` |
| StarRocks FE MySQL | `starrocks-fe:9030` |
| StarRocks BE HTTP | `http://starrocks-be:8040` |

Validate the StarRocks profile:

```bash
docker compose -f compose.yaml -f compose.starrocks.yaml --profile starrocks config
```

Start StarRocks:

```bash
docker compose -f compose.yaml -f compose.starrocks.yaml --profile starrocks up -d
```

Host port bindings can be overridden with:

| Variable | Default | Service port |
| --- | ---: | ---: |
| `STARROCKS_HTTP_PORT` | `8030` | FE HTTP `8030` |
| `STARROCKS_MYSQL_PORT` | `9030` | FE MySQL `9030` |
| `STARROCKS_BE_HTTP_PORT` | `8040` | BE HTTP `8040` |

## Data-Gov App State

The `data-gov` profile provides Neo4j for the `data-gov` application. Backend containers should use `bolt://neo4j:7687` on the shared network; host-side init scripts can use `bolt://localhost:${NEO4J_BOLT_PORT:-7687}`.

Validate the profile:

```bash
docker compose -f compose.yaml --profile data-gov config
```

Start Neo4j:

```bash
docker compose -f compose.yaml --profile data-gov up -d neo4j
```
