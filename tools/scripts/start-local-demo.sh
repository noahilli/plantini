#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/../.." && pwd)
e2e_dir="$repo_dir/tools/e2e"
env_file="$e2e_dir/.runtime/e2e.env"
app_url=http://127.0.0.1:3000
open_browser=true

if [ "${1:-}" = "--no-open" ]; then
  open_browser=false
elif [ "$#" -gt 0 ]; then
  echo 'Usage: tools/scripts/start-local-demo.sh [--no-open]' >&2
  exit 64
fi

(
  cd "$e2e_dir"
  npm run stack:up
)

username=$(awk -F= '$1 == "E2E_USERNAME" {sub(/^[^=]*=/, ""); print; exit}' "$env_file")
password=$(awk -F= '$1 == "E2E_USER_PASSWORD" {sub(/^[^=]*=/, ""); print; exit}' "$env_file")

curl -4 --fail --silent --show-error http://127.0.0.1:1338/api/v1/health >/dev/null
curl -4 --fail --silent --show-error "$app_url/healthz" >/dev/null

printf '\nPlantini-Demo ist bereit.\n'
printf 'Web-App:  %s\n' "$app_url"
printf 'Login:    %s\n' "$username"
printf 'Passwort: %s\n' "$password"
printf 'Modus:    deterministischer PlantNet-Mock, IPv4\n\n'

if [ "$open_browser" = true ]; then
  if command -v xdg-open >/dev/null 2>&1 && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }; then
    xdg-open "$app_url" >/dev/null 2>&1 &
    printf 'Browser wird geöffnet. Falls nichts erscheint: %s manuell öffnen.\n' "$app_url"
  else
    printf 'Keine grafische Browser-Session erkannt. Bitte den Link manuell öffnen.\n'
  fi
fi
