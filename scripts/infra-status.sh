#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

set -- compose
for file in compose.yaml compose.lakehouse.yaml compose.streaming.yaml compose.starrocks.yaml; do
  if [ -f "$repo_root/$file" ]; then
    set -- "$@" -f "$repo_root/$file"
  fi
done

cd "$repo_root"
docker "$@" ps
