'use strict';
module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/observations',
      handler: 'observation.find',
      config: { auth: false },
    },
    {
      method: 'POST',
      path: '/observations',
      handler: 'observation.create',
      config: { auth: false },
    },
    {
      method: 'GET',
      path: '/export/observations',
      handler: 'observation.exportObservations',
      config: { auth: false },
    }
  ]
};
