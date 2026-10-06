'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "bab5703345c366b520baf6e45dc2e14f",
".git/config": "16315650875d87f3c4e445d46601464e",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "e0b5b08e209fa15f48d796e8976bc42b",
".git/hooks/fsmonitor-watchman.sample": "5c90c1740b0cacecb469934e16fe8cb6",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "4dd8122dc3403e77529743a14d306cfb",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "50444a655cd0b2e51097ddb69e555977",
".git/logs/refs/heads/gh-pages": "5077538c6022bc3edc740321e5e7fe46",
".git/logs/refs/remotes/origin/gh-pages": "374a77a23b5bdff99c2c60e169b5713d",
".git/objects/00/bdb740045a94b4f97337bf4e8688e77ebadac6": "0540101940e49cb172be2ae9fa9d9aa8",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/0a/1a5b71370ac0ead3f38484a8985cb5b63fc77b": "2acfff223d2a80562846e7ed489d42f8",
".git/objects/13/da4bd091a342677d9517f48745d7990115783c": "eac64df75282ff158a6ddda3c2b022ae",
".git/objects/18/08500ea922ef3110427041a8460aeb6ca92406": "ddefaa8b3144a901b4cf32ea41c4291d",
".git/objects/1a/aa6188dd0e22e87aedc446f961bee73a9397c3": "18f41d266d716028ea2a1ce14a060277",
".git/objects/26/f5d1fb6454ce7da753845ce2142da8e468a4b6": "1228693bd398fd47beac2a141381cf9c",
".git/objects/33/c391c77b038e067211d25311cfae3ed1af03a7": "ce1f3441b73f4cbe72daab627159147f",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/3a/bf18c41c58c933308c244a875bf383856e103e": "30790d31a35e3622fd7b3849c9bf1894",
".git/objects/3c/0f4231f81957fd704158afd972133c5b4a2dc9": "48ee214dfed0323f0d0db3461a26e801",
".git/objects/42/114797faff91ad58aaf188a43ddd993a12f350": "a0af575192c1b2683f72982f078769d3",
".git/objects/4a/bb73c80e1ae4ce069d71bdc5debf33b26f6f35": "bb6639c3c1f657b0b3be42b519347fa3",
".git/objects/4b/8d680dd1d0b154f464bef10f3b21984f89a481": "ffcfeea5230722edf63add71be9def22",
".git/objects/4d/8dcb67a9f340c2f172b576ddf22a3b1e0fb810": "454750b147ec08eefae05e5d2af74135",
".git/objects/4d/a6c6bf97b327179964b56a43abfd1f486eb15b": "3f4bc5a3c14a80b98c43d81a354d97cc",
".git/objects/4d/aa850d5815be9d7099169faf7e8bedc8b217d3": "a8fc4619f98123592bdc74fcd49743fe",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/55/9d8ef10998f02bc7089271510765eb3ad273c9": "4d2ee235e42ecb7884229438b9cba342",
".git/objects/57/7593aacca9bce2e94c9f10748d02f45fbdb1ab": "3339f602577d7136bf9b358a05487b5d",
".git/objects/59/0e8a87e582d7258d88c2c6cf4e9e13488c9831": "50c456869bf789f1c1640cee397082f5",
".git/objects/5f/1a132fe324d232cb6712b5758e9498252893ba": "0dc81223e0d15337bc1ef299f5102a37",
".git/objects/60/30b983d5ce5fbd941d700e452f0e3551d43982": "943b520f545c46d0967059df41cd86c0",
".git/objects/60/f3b89f87665c2071c71451ff817d350080f68e": "3eef64edc4b77213dc68c23b0a04160d",
".git/objects/61/628e5efe1fea3881f378e5763d2f3c9a13c4f4": "94a54f5851036b868a887e8872cd5b88",
".git/objects/63/cb9604f28ba5da690fcd10f1b2b08b0919781e": "f69e973ecbeb1fce381f4acf7ab4c249",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6c/428c03ec703c7c7d3a2c3c3e31cf9bd64b176a": "a9a9ddc466f56592344d083d4f68947e",
".git/objects/6c/5220477b241f1fe76c40d5d48b41e095200980": "4211835ed150fb1ee83c85b9e97dd2b3",
".git/objects/6f/32c9b1f8098170f949d55619225e8b7d0b85a1": "6d59da18ebd20b2509d81fc939d30b51",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/73/2b4a47f449060c3a7fd0547b4615547251ca21": "d07cb4612cdada2aac06510c9a8d3519",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/83/44b40ff938ca0d15c146d3c19494972197f5cb": "3ce72ee7b74058093a41b4b87f1a01cd",
".git/objects/84/f1c1544486bc34a83415c495314769073838b1": "9f6d72b90213a7727388257b0dc2e4d6",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8c/5f3af021712f49ce991e1bfd9f9e543cb10cec": "b8ed9ca527ab714b8974446c0ba41846",
".git/objects/8e/21753cdb204192a414b235db41da6a8446c8b4": "1e467e19cabb5d3d38b8fe200c37479e",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/96/3e98983b169c5ee98a98e1ee0c45b5096a05d9": "c3ddf24af003d1c3f467bb426c3e8359",
".git/objects/96/887d35d7a85eaa6764ce4f3054b89449970712": "4efdd4eb00f9e9592be17229d5a0c5bd",
".git/objects/98/56a9d773031dc40f3bbc4b960e05a1d729d11f": "ed6565751ad1313e107b91e3e773f49d",
".git/objects/9f/0d3bec83113cacf580b3dc3147aff30d9b2487": "2f54431892e1dc2d6712562836db35f2",
".git/objects/a7/3f4b23dde68ce5a05ce4c658ccd690c7f707ec": "ee275830276a88bac752feff80ed6470",
".git/objects/a9/1360c53efb341798fbdcb9fc0c3a90d6763d11": "de17ee6a4099ede7c347e012c8ba798e",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/b5/518d507a4f93966feca75c37f183beff26a17a": "e1f5c1324b13b248ef71b3722e93a485",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/be/f73b5724d8fa0aaf097f5ba94788a438fbd202": "2bab6514113f069be3425733e01b20f7",
".git/objects/c0/81533839f8570f3519503b6bb437a6f474bec2": "3cc0004239ca9a727b5ab99b9d6b4a4a",
".git/objects/c1/0c080924a656f4d1aa54e599337f3125d1a435": "7dbc009e0abf8a4510796f3b491f264c",
".git/objects/c1/a5733782c419ea93b9948b8db86c52a2b66e71": "204d2f9b77f30a4c7976bd6a8336af54",
".git/objects/c7/925b85e23a8545e5b9b943aa194abd974e53c6": "a2b4417255e77c04477d5e3c91ef3886",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/c9/91dc56eebec5d9c9a1666f28cf3fa5d54f1e3d": "51a930fc5bf32add14b095ade4f976a4",
".git/objects/d0/290db1c786573cae44050faabfb3cf94a37261": "61ce28203950b96903462b807615ccaa",
".git/objects/d0/a5a9ceb663b97e5129f5dd2f4f5779f012f2a9": "a74a8af7db045ba289d24aaddb1bbc00",
".git/objects/d0/bb5db9bd2841171acef0d182894dc6b05b6c24": "df4c352f212b1efb86f8b9a0924ee15d",
".git/objects/d2/25d12991264d68fe71ab39fbdeaea02ed6678f": "febcc2d1e707197860021905565ebf7d",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d4/b87b49b5ee644a2e4536f1306d7d8f0056e8a1": "b929fc14a6e67b7cec8cb62943532232",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/e7/d106c4421e680481973b9d78dfbe4f0f09ed97": "f80fd6cdcf1f6c406f9dcf4ca6c55fc7",
".git/objects/e8/97073cf6cf20a5bb12a357502813226227f81d": "0684662bc5ca7fe8ea27cf0cd4cce9b2",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/f3/e2c5bb10679e4e0e7a02802021e384f1e08eee": "c242bbbc110215d5b51522d23baa7413",
".git/objects/f5/0bd726f8350275a316306b70e2d1486203e57b": "14b08c19b6d64b9e60af6b02eaa3b313",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/fa/9ff9b92a5dfe81cc8112a80d50f4dd75caa001": "3e006f7238f8b5de87e138d7aa53279e",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/refs/heads/gh-pages": "390329464b0bbacb30ccd8b1f2801605",
".git/refs/remotes/origin/gh-pages": "390329464b0bbacb30ccd8b1f2801605",
"assets/AssetManifest.bin": "85f2314d16a709a18ef103b32d2bf777",
"assets/AssetManifest.bin.json": "b43f35bfab812a7c5541b0d68d16cd07",
"assets/assets/dfd8836b1cc110e21d03c83043dcb710.jpg": "fbcfa1fbe4e15977d876e280bba41d06",
"assets/assets/e5fc9263-35b4-4d4b-bc8e-14ff17aa93f0.png": "9884ffea02d53344b5bf8f8e34496a67",
"assets/assets/google_icon.png": "937c87b4439809d5b17b82728df09639",
"assets/assets/icons8-google-48.png": "937c87b4439809d5b17b82728df09639",
"assets/assets/Login%2520Ui.jpg": "2e25dab9290b94700c5b7bbe2d9926de",
"assets/assets/Login%2520Ui1.jpg": "4620b8b61448d8d0193300a14067ec2b",
"assets/assets/Login%2520Uim.jpg": "220bd501431ec54ff13673bf9271680c",
"assets/assets/login_ui.jpg": "4620b8b61448d8d0193300a14067ec2b",
"assets/assets/login_ui1.jpg": "4620b8b61448d8d0193300a14067ec2b",
"assets/assets/teacher_photo.jpg": "fbcfa1fbe4e15977d876e280bba41d06",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "3306acbade67c233e83e959775d8ac90",
"assets/NOTICES": "874d10e91c8c160f22a04b21d19fc161",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "ab736cb5d43bb538ba1f82960be7c654",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "915d532648e922fff35e8b8996b26516",
"/": "915d532648e922fff35e8b8996b26516",
"main.dart.js": "5f07fc3df3c7f1c01ce089ffdba639aa",
"manifest.json": "89ad0623a1618ac1bce2ffa0a5630c95",
"version.json": "025b19c66800f4b9d790c04707afcd19"};
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
