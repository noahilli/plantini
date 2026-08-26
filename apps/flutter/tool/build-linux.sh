#!/usr/bin/env bash
set -euo pipefail

# Flutter reads dart-defines at compile time. A Linux bundle built without
# these values can only show the configuration error screen on first launch.
# Do not add endpoint defaults here: a missing deployment configuration must
# fail before an artefact is published.
for required in PLANTINI_ENV PLANTINI_API_BASE_URL PLANTINI_OIDC_ISSUER_URL PLANTINI_OIDC_CLIENT_ID; do
  if [[ -z "${!required:-}" ]]; then
    printf 'Missing required build variable: %s\n' "$required" >&2
    exit 64
  fi
done

case "$PLANTINI_ENV" in
  development|staging|production) ;;
  *)
    printf 'PLANTINI_ENV must be development, staging, or production.\n' >&2
    exit 64
    ;;
esac

for endpoint in "$PLANTINI_API_BASE_URL" "$PLANTINI_OIDC_ISSUER_URL"; do
  if [[ "$endpoint" == *'['* || "$endpoint" == *']'* ]]; then
    printf 'IPv6 endpoint literals are not supported for the Linux deployment. Use IPv4 or an IPv4-routed hostname.\n' >&2
    exit 64
  fi
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
app_dir="$(cd "$script_dir/.." && pwd)"

cd "$app_dir"
exec flutter build linux --release \
  --dart-define="PLANTINI_ENV=$PLANTINI_ENV" \
  --dart-define="PLANTINI_API_BASE_URL=$PLANTINI_API_BASE_URL" \
  --dart-define="PLANTINI_OIDC_ISSUER_URL=$PLANTINI_OIDC_ISSUER_URL" \
  --dart-define="PLANTINI_OIDC_CLIENT_ID=$PLANTINI_OIDC_CLIENT_ID"
