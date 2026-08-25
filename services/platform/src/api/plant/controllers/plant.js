"use strict";
const { createCoreController } = require("@strapi/strapi").factories;

module.exports = createCoreController("api::plant.plant", ({ strapi }) => ({
  async find(ctx) {
    try {
      const plants = await strapi.entityService.findMany('api::plant.plant', {
        fields: ['id', 'scientificName', 'commonName', 'family', 'description'],
      });
      const data = plants.map(plant => ({
        id: String(plant.id),
        scientificName: plant.scientificName || '',
        commonName: plant.commonName || '',
        family: plant.family || '',
        description: plant.description || ''
      }));
      return data;
    } catch (err) {
      ctx.throw(500, 'Error fetching plants');
    }
  },

  async findOne(ctx) {
    const { id } = ctx.params;
    try {
      const plant = await strapi.entityService.findOne('api::plant.plant', id, {
        fields: ['id', 'scientificName', 'commonName', 'family', 'description'],
      });
      if (!plant) {
        return ctx.notFound('Plant not found');
      }
      return {
        id: String(plant.id),
        scientificName: plant.scientificName || '',
        commonName: plant.commonName || '',
        family: plant.family || '',
        description: plant.description || ''
      };
    } catch (err) {
      ctx.throw(500, 'Error fetching plant');
    }
  }
}));
