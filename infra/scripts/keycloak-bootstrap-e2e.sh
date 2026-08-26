#!/bin/sh
set -eu

: "${E2E_KEYCLOAK_ADMIN_USERNAME:?missing E2E_KEYCLOAK_ADMIN_USERNAME}"
: "${E2E_KEYCLOAK_ADMIN_PASSWORD:?missing E2E_KEYCLOAK_ADMIN_PASSWORD}"
: "${E2E_USERNAME:?missing E2E_USERNAME}"
: "${E2E_USER_PASSWORD:?missing E2E_USER_PASSWORD}"
: "${E2E_USER_EMAIL:?missing E2E_USER_EMAIL}"

KCADM=/opt/keycloak/bin/kcadm.sh

attempt=1
while ! "$KCADM" config credentials \
  --server http://keycloak:8080 \
  --realm master \
  --user "$E2E_KEYCLOAK_ADMIN_USERNAME" \
  --password "$E2E_KEYCLOAK_ADMIN_PASSWORD"; do
  if [ "$attempt" -ge 30 ]; then
    echo 'Keycloak admin API did not become available.' >&2
    exit 1
  fi
  attempt=$((attempt + 1))
  sleep 2
done

find_user_id() {
  "$KCADM" get users -r plantini -q "email=$E2E_USER_EMAIL" \
    --fields id --format csv --noquotes | sed -n '1p'
}

# The realm deliberately uses email addresses as login names. Looking users up
# by email keeps this bootstrap idempotent even when Keycloak normalizes the
# submitted username to that email address.
USER_ID="$(find_user_id)"
if [ -z "$USER_ID" ]; then
  "$KCADM" create users -r plantini \
    -s "username=$E2E_USER_EMAIL" \
    -s "email=$E2E_USER_EMAIL" \
    -s 'enabled=true' \
    -s 'emailVerified=true' \
    -s 'requiredActions=[]'
  USER_ID="$(find_user_id)"
fi

if [ -z "$USER_ID" ]; then
  echo 'Could not find the synthetic E2E learner after creation.' >&2
  exit 1
fi

"$KCADM" update "users/$USER_ID" -r plantini \
  -s "username=$E2E_USER_EMAIL" \
  -s "email=$E2E_USER_EMAIL" \
  -s 'enabled=true' \
  -s 'emailVerified=true' \
  -s 'requiredActions=[]'
"$KCADM" set-password -r plantini --userid "$USER_ID" --new-password "$E2E_USER_PASSWORD"
echo 'Synthetic E2E learner is ready.'
