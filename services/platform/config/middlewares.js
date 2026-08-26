module.exports = ({ env }) => {
  const origins = env.array('CORS_ORIGINS', []);
  return [
    'strapi::logger',
    'strapi::errors',
    'strapi::security',
    {
      name: 'strapi::cors',
      config: {
        origin: origins,
        methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
        headers: ['Content-Type', 'Authorization', 'Idempotency-Key', 'If-Match', 'If-None-Match', 'X-Correlation-Id'],
        keepHeaderOnError: true,
      },
    },
    'strapi::poweredBy',
    'strapi::query',
    {
      name: 'strapi::body',
      config: {
        formLimit: '21mb',
        jsonLimit: '1mb',
        textLimit: '1mb',
        formidable: {
          maxFileSize: 20 * 1024 * 1024,
          maxFiles: 1,
          multiples: false,
          keepExtensions: false,
        },
      },
    },
    'strapi::session',
    'strapi::favicon',
    'strapi::public',
  ];
};
