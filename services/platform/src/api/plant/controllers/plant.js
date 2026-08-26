'use strict';

const { createCoreController } = require('@strapi/strapi').factories;

// Editorial CRUD remains protected by Strapi administration permissions. The
// mobile client uses only the audited /api/v1 projection.
module.exports = createCoreController('api::plant.plant');
