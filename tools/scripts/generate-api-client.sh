#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
generator_image="openapitools/openapi-generator-cli:v7.25.0@sha256:2ab0a9680222de65dc9d3baf861aa02b99e1b80c211d8221ebf3ae8f8a102524"
output_dir="$(mktemp -d -t plantini-api-client.XXXXXX)"
cleanup() { rm -rf "${output_dir:?}"; }
trap cleanup EXIT

docker run --rm \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$repo_dir/contracts,dst=/local/contracts,readonly" \
  --mount "type=bind,src=$output_dir,dst=/out" \
  "$generator_image" generate \
  -i /local/contracts/api.yaml \
  -g dart-dio \
  -o /out \
  --additional-properties=pubName=openapi,pubVersion=1.0.0,serializationLibrary=built_value

# packages/api is entirely generator-owned. Preserve only local pub/build
# caches, which are ignored and recreated by Dart tooling.
rsync -a --delete \
  --exclude=.dart_tool/ \
  --exclude=build/ \
  --exclude=pubspec.lock \
  "$output_dir/" "$repo_dir/packages/api/"

# The upstream templates currently emit imports that are valid across all
# response shapes but unused for some APIs. Keep that generator noise from
# weakening analysis of handwritten code.
cp "$repo_dir/tools/openapi/analysis_options.yaml" \
  "$repo_dir/packages/api/analysis_options.yaml"

find "$repo_dir/packages/api" \
  -path "$repo_dir/packages/api/.dart_tool" -prune -o \
  -type f \( \
    -name '*.dart' -o \
    -name '*.md' -o \
    -name '*.yaml' -o \
    -name '.gitignore' -o \
    -name '.openapi-generator-ignore' \
  \) -exec perl -0pi -e 's/[ \t]+$//mg; s/\n+\z/\n/' {} +

(
  cd "$repo_dir/packages/api"
  dart pub get
  dart run build_runner build
  dart format lib test
)

node "$repo_dir/tools/scripts/validate-api-contract.mjs" --write-digests

echo "Dart API client regenerated with OpenAPI Generator 7.25.0"
