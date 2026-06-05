# Baseline

## data-benchmark

Run these commands from `D:\agent-code\data-benchmark`.

- Compose: `docker compose -f docker-compose.yml config`
- Unit tests: `mvn test`
- Smoke:
  - `mvn package`
  - `docker compose -f docker-compose.yml build benchmark-runner`
  - `cd D:\agent-code\shared-data-infra`
  - `docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse up -d`
  - `cd D:\agent-code\data-benchmark`
  - `docker compose -f docker-compose.yml up -d spark starrocks-fe starrocks-be`
  - `java -jar target/data-benchmark-0.1.0-SNAPSHOT.jar run --mode compose --config configs/benchmark-compose-smoke.yml --run-id compose-smoke`

Services from current compose:

```text
hdfs-namenode
hdfs-datanode
hdfs-init
hive-metastore
hive-server
spark
starrocks-fe
starrocks-be
benchmark-runner
```

## flink-data-balance

Run these commands from `D:\agent-code\flink-data-balance`.

- Compose: `docker compose -f docker/docker-compose.yml config`
- Unit tests: `mvn test`
- E2E: `bash scripts/e2e-smoke-test.sh`
- E2E summary: `FDB_E2E_SUMMARY=1 bash scripts/e2e-smoke-test.sh`

Services from current compose:

```text
zookeeper
kafka
kafka-ui
observability-api
prometheus
hms-postgres
mysql
frontend
grafana
hive-metastore
```

## data-gov

Run these commands from `D:\agent-code\data-gov`.

- Base compose: `docker compose -f base-compose.yml config`
- App compose: `docker compose -f app-compose.yml config`
- Unit tests: `python -m pytest -m "not infra"`
- Infra tests: `python -m pytest -m infra`

Services from current base compose:

```text
namenode
datanode
hms-db
hive-metastore
resourcemanager
nodemanager
kafka
neo4j
starrocks
```

Services from current app compose:

```text
backend
frontend
```
