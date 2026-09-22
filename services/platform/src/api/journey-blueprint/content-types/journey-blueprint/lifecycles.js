'use strict';

const { generateBlueprintDrafts } = require('../../../platform/services/core/content/journey-authoring');

// Admin Content Manager only: no public CRUD router is registered for this type.
// Hooks run after components/relations have been saved by Entity Service.
async function generate(event) {
  if (event.result.generateDrafts === true) {
    await generateBlueprintDrafts(strapi, event.result.id);
  }
}

module.exports = { afterCreate: generate, afterUpdate: generate };
