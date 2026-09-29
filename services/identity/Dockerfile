# syntax=docker/dockerfile:1.7
# Production Keycloak with the build-time options baked in, so the container
# can run `start --optimized`. Keep the version identical to the tested
# development/E2E image (infra/compose.e2e.yaml).
FROM quay.io/keycloak/keycloak:24.0.4 AS build
ENV KC_DB=postgres \
    KC_HEALTH_ENABLED=true
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:24.0.4
COPY --from=build /opt/keycloak/ /opt/keycloak/
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
