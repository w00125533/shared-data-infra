# Shared Data Infrastructure

This repository owns shared local infrastructure for `data-benchmark`, `flink-data-balance`, and `data-gov`.

## Profiles

- `lakehouse`: HDFS, Hive Metastore.
- `lakehouse-tools`: HiveServer2 and Spark tools.
- `yarn`: ResourceManager and NodeManager.
- `streaming`: Kafka and ZooKeeper/KRaft.
- `starrocks`: StarRocks.
- `observability`: Prometheus, Grafana, Kafka UI.

## Network

All shared services are attached to Docker network `shared-data-infra`.

Project compose files should connect app containers to this external network and use environment variables for endpoints.
