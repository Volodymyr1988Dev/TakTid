const CACHE_NAME = 'taktid-v1'

self.addEventListener('install', event => {
  self.skipWaiting()
})

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.map(key => {
          if (key !== CACHE_NAME) {
            return caches.delete(key)
          }
        })
      )
    )
  )
  self.clients.claim()
})
/*
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return

  event.respondWith(
    caches.match(event.request).then(response => {
      return (
        response ||
        fetch(event.request).then(fetchResponse => {
          return caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, fetchResponse.clone())
            return fetchResponse
          })
        })
      )
    })
  )
})*/
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url)

  if (url.pathname.startsWith('/api')) {
    event.respondWith(fetch(event.request))
    return
  }

  if (event.request.method !== 'GET') return

  event.respondWith(
    caches.match(event.request).then(response => {
      return (
        response ||
        fetch(event.request).then(fetchResponse => {
          return caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, fetchResponse.clone())
            return fetchResponse
          })
        })
      )
    })
  )
})