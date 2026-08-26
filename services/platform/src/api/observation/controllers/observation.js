'use strict';

const { createCoreController } = require('@strapi/strapi').factories;

// No public Strapi observation API: caller-owned herbarium access is enforced
// exclusively in api::platform's Keycloak-authenticated v1 routes.
module.exports = createCoreController('api::observation.observation');
