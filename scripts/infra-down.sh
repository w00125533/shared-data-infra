#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
include_volumes=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--volumes)
      include_volumes=1
      ;;
    *)
      echo "Usage: $0 [-v|--volumes]" >&2
      exit 2
      ;;
  esac
  shift
done

set -- compose
for file in compose.yaml compose.lakehouse.yaml compose.streaming.yaml compose.starrocks.yaml; do
  if [ -f "$repo_root/$file" ]; then
    set -- "$@" -f "$repo_root/$file"
  fi
done

cd "$repo_root"
if [ "$include_volumes" -eq 1 ]; then
  docker "$@" down -v
else
  docker "$@" down
fi
