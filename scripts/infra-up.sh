#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
profiles="${*:-lakehouse}"

set -- compose
for file in compose.yaml compose.lakehouse.yaml compose.streaming.yaml compose.starrocks.yaml; do
  if [ -f "$repo_root/$file" ]; then
    set -- "$@" -f "$repo_root/$file"
  fi
done

old_ifs=$IFS
IFS=', '
for profile in $profiles; do
  if [ -n "$profile" ]; then
    set -- "$@" --profile "$profile"
  fi
done
IFS=$old_ifs

cd "$repo_root"
docker "$@" up -d
docker "$@" ps
