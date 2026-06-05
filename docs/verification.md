# Verification

## Shared Infra

- `docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse config`: PASS
- `docker compose -f compose.yaml -f compose.lakehouse.yaml --profile lakehouse --profile yarn --profile spark-tools config`: PASS
- `docker compose -f compose.yaml -f compose.streaming.yaml --profile streaming config`: PASS
- `docker compose -f compose.yaml -f compose.starrocks.yaml --profile starrocks config`: PASS
- `docker compose -f compose.yaml --profile data-gov config`: PASS
- `sh scripts/infra-status.sh`: PASS

## data-benchmark

- `docker compose -f docker-compose.yml config`: PASS
- `mvn -Dtest=ComposeTopologyTest test`: PASS
- `mvn test`: PASS

## flink-data-balance

- `docker compose -f docker/docker-compose.yml --profile e2e config`: PASS
- `bash -n scripts/dev-up.sh; bash -n scripts/dev-down.sh; bash -n scripts/e2e-smoke-test.sh; bash -n scripts/create-kafka-topics.sh`: PASS
- `mvn test`: PASS

Note: changes were not committed in `flink-data-balance` because the worktree already contained extensive overlapping user changes.

## data-gov

- `docker compose -f base-compose.yml config`: PASS
- `docker compose -f ../shared-data-infra/compose.yaml -f ../shared-data-infra/compose.lakehouse.yaml --profile data-gov --profile lakehouse --profile yarn --profile spark-tools config`: PASS
- `docker compose -f app-compose.yml config`: PASS
- `bash -n scripts/init-stack.sh; bash -n scripts/wait-for-healthy.sh; bash -n init-scripts/02_kafka_init.sh`: PASS
- `python -m pytest tests/api/test_fake_data.py tests/sandbox/test_hdfs.py -q`: PASS
- `python -m pytest -m "not infra"` with container-internal sandbox endpoint environment overrides: PASS

Note: full shared profile startup and project e2e/infra smoke flows were not run because existing local containers/ports could conflict in the shared machine.
