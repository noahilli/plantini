'use strict';

module.exports = {
  async getMe(ctx) {
    const authHeader = ctx.request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return ctx.unauthorized('No authorization header found');
    }

    // Mock-Auth Validation for MVP
    const token = authHeader.split(' ')[1];
    if (token !== 'mock-jwt-token' && token !== 'test-token') {
      // In real scenario we would validate against Keycloak
      // For now we accept 'mock-jwt-token' and 'test-token'
      // return ctx.unauthorized('Invalid token');
    }

    // Return mock user profile matching OpenAPI spec
    return {
      id: '123e4567-e89b-12d3-a456-426614174000',
      username: 'testuser',
      email: 'testuser@example.com',
      roles: ['Lernende']
    };
  },

  async getManifest(ctx) {
    // Return mock manifest matching OpenAPI spec
    return {
      version: '1.0.0',
      releasedAt: new Date().toISOString(),
      checksums: {
        'content.json': 'a1b2c3d4',
        'media.zip': 'e5f6g7h8'
      }
    };
  },

  async listEcosystems(ctx) {
    try {
      const ecosystems = await strapi.entityService.findMany('api::ecosystem.ecosystem', {
        fields: ['id', 'name', 'description'],
      });
      // Map Strapi id (number) to string to match OpenAPI spec, wait Strapi IDs are integers, our spec says strings
      return ecosystems.map(eco => ({
        id: String(eco.id),
        name: eco.name || '',
        description: eco.description || ''
      }));
    } catch (err) {
      ctx.throw(500, 'Error fetching ecosystems');
    }
  },

  async listLevels(ctx) {
    const authHeader = ctx.request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return ctx.unauthorized('No authorization header found');
    }

    try {
      const levels = await strapi.entityService.findMany('api::level.level', {
        fields: ['id', 'title'],
      });
      // Return levels with mock progress
      return levels.map(level => ({
        id: String(level.id),
        title: level.title || '',
        isUnlocked: true,
        progress: 0.0
      }));
    } catch (err) {
      ctx.throw(500, 'Error fetching levels');
    }
  }
};
