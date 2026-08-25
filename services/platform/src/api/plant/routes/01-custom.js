'use strict';
module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/plants',
      handler: 'plant.find',
      config: { auth: false },
    },
    {
      method: 'GET',
      path: '/plants/:id',
      handler: 'plant.findOne',
      config: { auth: false },
    }
  ]
};
