'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "97deb2a72a0b47187c74d56e071be01b",
"assets/AssetManifest.bin.json": "3603b67f397be4c480f20774d9f32df8",
"assets/AssetManifest.json": "eaa1fd1da116bcf59d959065ea4a81fc",
"assets/assets/images/brasilia.png": "686df260c19fc55fe1811f631637f095",
"assets/assets/images/bus.png": "0d5507b9bd1bbb2da0ccf8214ceb51f2",
"assets/assets/images/BusStop.png": "4fe55d1e5f7757a1f78100ed990a4814",
"assets/assets/images/defaultBus.png": "f99b24e3342da49814351a0e3dedc29f",
"assets/assets/images/gdf-logo.png": "2826ffa225e34eba10c0189294b108f5",
"assets/assets/images/icon_bus.png": "01e9631636dba7c924c41786de1bced5",
"assets/assets/images/icon_bus_azul.png": "597409b55c8c7cc8e030914c4f9f04c0",
"assets/assets/images/logo.png": "fd0e8d79d444bc1a896f83b71c691ded",
"assets/assets/images/marechalBus.png": "98eaf742eefd117344bdd26ccf795106",
"assets/assets/images/ouvidoria.webp": "ff13fadeb473f2efe6a58db189c57f89",
"assets/assets/images/pioneiraBus.png": "4eaaa625db5262d07baa326d013bf694",
"assets/assets/images/piracicabanaBus.png": "46a4c500976c0cfa895deb8013824b7c",
"assets/assets/images/sao_joseBus.png": "3d85a3d3dd69ae952e4459575367b209",
"assets/assets/images/urbiBus.png": "817e5e570e8cab8c17c4236167fe67fe",
"assets/assets/images/user.png": "e33f29558d4af59e50aa4f63a77e5317",
"assets/assets/images/user_location.png": "f8614826090c6b2f0de6383f47cfe598",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "bef0cd018f02d1380c333e687763d3c4",
"assets/NOTICES": "272420b4bf40402db082bef448828619",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "82e8f7e03cd63a3adc15d4ef197b839f",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "f3ceb645cd5d2ac47b7245c6a6b38e57",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "aa0ba67febf0d70ba465cd82bd2bad2d",
"/": "aa0ba67febf0d70ba465cd82bd2bad2d",
"info_onibus_web/.git/COMMIT_EDITMSG": "d778d8b1f42d0dd1bb284e5ca9549187",
"info_onibus_web/.git/config": "5c3a19824ae1687ea14bf37b634baca5",
"info_onibus_web/.git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
"info_onibus_web/.git/FETCH_HEAD": "ef48f985b608b53c6ab1bc267c286191",
"info_onibus_web/.git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
"info_onibus_web/.git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
"info_onibus_web/.git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
"info_onibus_web/.git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
"info_onibus_web/.git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
"info_onibus_web/.git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
"info_onibus_web/.git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
"info_onibus_web/.git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
"info_onibus_web/.git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
"info_onibus_web/.git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
"info_onibus_web/.git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
"info_onibus_web/.git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
"info_onibus_web/.git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
"info_onibus_web/.git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
"info_onibus_web/.git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
"info_onibus_web/.git/index": "e00da50f953b53a17e6f226c8b33a430",
"info_onibus_web/.git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
"info_onibus_web/.git/logs/HEAD": "b9694298cad2b0af8cb7ba2aff00af5a",
"info_onibus_web/.git/logs/refs/heads/main": "b9694298cad2b0af8cb7ba2aff00af5a",
"info_onibus_web/.git/logs/refs/remotes/origin/HEAD": "c6566a9daa996b6c6beffddacd5f3b1d",
"info_onibus_web/.git/logs/refs/remotes/origin/main": "ccaef72a95490e7bed392c214b40110f",
"info_onibus_web/.git/objects/64/5a822458b1e7b39b835168f2bddf849e227832": "922dc509fced2c0c4b792edb3270092b",
"info_onibus_web/.git/objects/6f/9509c88bed7080d496fc5e1d87a9315e30549d": "c02716d7aaed30ce1c5697a2fb40d317",
"info_onibus_web/.git/objects/df/e0770424b2a19faf507a501ebfc23be8f54e7b": "76f8baefc49c326b504db7bf751c967d",
"info_onibus_web/.git/refs/heads/main": "d9470119713dea215db974d74c1d56dd",
"info_onibus_web/.git/refs/remotes/origin/HEAD": "98b16e0b650190870f1b40bc8f4aec4e",
"info_onibus_web/.git/refs/remotes/origin/main": "d9470119713dea215db974d74c1d56dd",
"main.dart.js": "8c1c4567e0c5588f8e86e55c729c953f",
"manifest.json": "02d63fab6bbfbe303b7e57e0fe9b2c49",
"version.json": "96656584df42ce7af7edbe2b9daf30d5"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
