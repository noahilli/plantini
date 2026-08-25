'use strict';
const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::observation.observation', ({ strapi }) => ({
  async find(ctx) {
    const authHeader = ctx.request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return ctx.unauthorized('No authorization header found');
    }
    const mockUserId = '123e4567-e89b-12d3-a456-426614174000'; // mock user

    try {
      const observations = await strapi.entityService.findMany('api::observation.observation', {
        filters: { userId: mockUserId },
        populate: {
          photo: { populate: ['file'] },
          plant: true
        },
      });

      const data = observations.map(obs => {
        // Location fuzzing logic (2 decimal places ~ 1.1km precision)
        let lat = obs.latitude ? Math.round(obs.latitude * 100) / 100 : undefined;
        let lon = obs.longitude ? Math.round(obs.longitude * 100) / 100 : undefined;

        let imageUrl = '';
        if (obs.photo && obs.photo.file) {
          imageUrl = obs.photo.file.url || '';
        }

        let plantName = 'Unbekannte Pflanze';
        if (obs.plant) {
          plantName = obs.plant.commonName ? `${obs.plant.commonName} (${obs.plant.scientificName})` : obs.plant.scientificName;
        } else if (obs.notes) {
          plantName = obs.notes;
        }

        return {
          id: String(obs.id),
          plantName: plantName,
          date: obs.timestamp,
          imageUrl: imageUrl,
          notes: obs.notes || '',
          location: (lat !== undefined && lon !== undefined) ? { lat, lon } : undefined,
          identificationScore: obs.plantnetScores ? obs.plantnetScores.score : null
        };
      });
      return data;
    } catch (err) {
      console.error(err);
      ctx.throw(500, 'Error fetching observations');
    }
  },

  async create(ctx) {
    const authHeader = ctx.request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return ctx.unauthorized('No authorization header found');
    }
    const mockUserId = '123e4567-e89b-12d3-a456-426614174000';

    try {
      let body = ctx.request.body || {};
      let files = ctx.request.files || {};
      
      const imageFile = files.image;
      const notes = body.notes || '';
      const latitude = body.latitude ? parseFloat(body.latitude) : null;
      const longitude = body.longitude ? parseFloat(body.longitude) : null;
      
      let uploadedPhoto = null;

      if (imageFile) {
        const uploadService = strapi.plugin('upload').service('upload');
        const uploadedFiles = await uploadService.upload({
          data: {},
          files: imageFile
        });
        if (uploadedFiles && uploadedFiles.length > 0) {
          const coreFileId = uploadedFiles[0].id;
          const mediaEntry = await strapi.entityService.create('api::media.media', {
            data: {
              title: imageFile.name || 'Observation photo',
              file: coreFileId,
              publishedAt: new Date().toISOString()
            },
            populate: ['file']
          });
          uploadedPhoto = mediaEntry;
        }
      }

      let mockScore = body.score ? parseFloat(body.score) : 0.88;
      const plantId = body.plantId ? parseInt(body.plantId) : (body.plant ? parseInt(body.plant) : null);

      const observation = await strapi.entityService.create('api::observation.observation', {
        data: {
          userId: mockUserId,
          timestamp: new Date().toISOString(),
          latitude: latitude,
          longitude: longitude,
          notes: notes,
          photo: uploadedPhoto ? uploadedPhoto.id : null,
          plant: plantId || null,
          plantnetScores: { score: mockScore }
        },
        populate: ['photo', 'plant']
      });

      let fuzzedLat = observation.latitude ? Math.round(observation.latitude * 100) / 100 : undefined;
      let fuzzedLon = observation.longitude ? Math.round(observation.longitude * 100) / 100 : undefined;

      let uploadedUrl = '';
      if (uploadedPhoto && uploadedPhoto.file) {
        uploadedUrl = uploadedPhoto.file.url || '';
      }

      let plantName = body.plantName || 'Waldmeister (Galium odoratum)';
      if (observation.plant) {
        plantName = observation.plant.commonName ? `${observation.plant.commonName} (${observation.plant.scientificName})` : observation.plant.scientificName;
      }

      return {
        id: String(observation.id),
        plantName: plantName,
        date: observation.timestamp,
        imageUrl: uploadedUrl,
        notes: observation.notes || '',
        location: (fuzzedLat !== undefined && fuzzedLon !== undefined) ? { lat: fuzzedLat, lon: fuzzedLon } : undefined,
        identificationScore: mockScore
      };
    } catch (err) {
      console.error(err);
      ctx.throw(500, 'Error creating observation');
    }
  },

  async exportObservations(ctx) {
    const authHeader = ctx.request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return ctx.unauthorized('No authorization header found');
    }

    const { organisationId } = ctx.query;
    
    let filters = {};
    if (organisationId) {
      filters.organisationId = organisationId;
    }

    try {
      const observations = await strapi.entityService.findMany('api::observation.observation', {
        filters: filters,
        populate: {
          photo: { populate: ['file'] },
          plant: true
        }
      });

      const data = observations.map(obs => {
        let lat = obs.latitude ? Math.round(obs.latitude * 100) / 100 : undefined;
        let lon = obs.longitude ? Math.round(obs.longitude * 100) / 100 : undefined;

        let imageUrl = '';
        if (obs.photo && obs.photo.file) {
          imageUrl = obs.photo.file.url || '';
        }

        return {
          id: String(obs.id),
          plantName: obs.plant ? obs.plant.scientificName : 'Unknown',
          date: obs.timestamp,
          imageUrl: imageUrl,
          notes: obs.notes || '',
          lat: lat,
          lon: lon,
          identificationScore: obs.plantnetScores ? obs.plantnetScores.score : null
        };
      });

      const accepts = ctx.accepts('json', 'csv');
      if (accepts === 'csv' || ctx.query.format === 'csv') {
        if (data.length === 0) {
          ctx.set('Content-Type', 'text/csv');
          return 'id,plantName,date,imageUrl,notes,lat,lon,identificationScore\n';
        }
        const keys = Object.keys(data[0]);
        const csvRows = [];
        csvRows.push(keys.join(','));
        for (const row of data) {
          const values = keys.map(k => {
            const val = row[k];
            if (val === null || val === undefined) return '';
            const str = String(val);
            if (str.includes(',') || str.includes('"') || str.includes('\n')) {
              return `"${str.replace(/"/g, '""')}"`;
            }
            return str;
          });
          csvRows.push(values.join(','));
        }
        ctx.set('Content-Type', 'text/csv');
        ctx.set('Content-Disposition', 'attachment; filename="observations_export.csv"');
        return csvRows.join('\n');
      }

      return data;
    } catch (err) {
      console.error(err);
      ctx.throw(500, 'Error exporting observations');
    }
  }
}));
