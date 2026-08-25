"use strict";
const { createCoreController } = require("@strapi/strapi").factories;

module.exports = createCoreController("api::media.media", ({ strapi }) => ({
  async find(ctx) {
    try {
      const mediaItems = await strapi.entityService.findMany('api::media.media', {
        fields: ['id', 'title', 'caption', 'license', 'author'],
        populate: ['file']
      });
      const data = mediaItems.map(item => {
        let url = '';
        if (item.file) {
          url = item.file.url || '';
        }
        return {
          id: String(item.id),
          title: item.title || '',
          caption: item.caption || '',
          license: item.license || '',
          author: item.author || '',
          url: url
        };
      });
      return data;
    } catch (err) {
      ctx.throw(500, 'Error fetching media');
    }
  }
}));
