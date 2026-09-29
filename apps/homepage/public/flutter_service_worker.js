// The Flutter web app used to be served from this origin and registered a
// service worker here. Returning visitors would keep getting the cached app
// instead of the homepage, so this replacement removes itself and reloads.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    await self.registration.unregister();
    for (const client of await self.clients.matchAll({ type: 'window' })) client.navigate(client.url);
  })());
});
