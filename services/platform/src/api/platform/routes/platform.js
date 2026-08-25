module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/me',
      handler: 'api::platform.platform.getMe',
      config: {
        auth: false,
      },
    },
    {
      method: 'GET',
      path: '/manifest',
      handler: 'api::platform.platform.getManifest',
      config: {
        auth: false,
      },
    },
    {
      method: 'GET',
      path: '/ecosystem',
      handler: 'api::platform.platform.listEcosystems',
      config: {
        auth: false,
      },
    },
    {
      method: 'GET',
      path: '/level',
      handler: 'api::platform.platform.listLevels',
      config: {
        auth: false,
      },
    }
  ],
};
