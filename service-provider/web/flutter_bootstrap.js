{{flutter_js}}
{{flutter_build_config}}

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    for (var registration of registrations) {
      registration.unregister();
    }
  });
  if (window.caches) {
    caches.keys().then(function(names) {
      for (var name of names) caches.delete(name);
    });
  }
}

_flutter.loader.load();
