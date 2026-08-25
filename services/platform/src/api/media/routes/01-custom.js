'use strict';
module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/media',
      handler: 'media.find',
      config: { auth: false },
    }
  ]
};
