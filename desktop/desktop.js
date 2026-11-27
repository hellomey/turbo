// Desktop gate (design/ui/desktop.png). On a wide screen with a mouse, show the "Try it on your mobile phone" page
// with a QR code instead of loading the app. "Open here" loads the app in this browser and is remembered for the
// tab. Phones and tablets load the app straight away. Lives in its own file because the CSP blocks inline scripts.
(function () {
  var MOBILE_LINK = 'https://heymey.app/try?src=desktop';
  var KEY = 'hm-desktop-ok';

  function loadApp() {
    var page = document.getElementById('hm-desktop');
    if (page) page.className = '';
    var s = document.createElement('script');
    s.src = 'flutter_bootstrap.js';
    s.async = true;
    document.body.appendChild(s);
  }

  function remembered() {
    try { return sessionStorage.getItem(KEY) === '1'; } catch (e) { return false; }
  }

  var forced = /[?&]app=1\b/.test(location.search);
  var wide = window.innerWidth >= 1024;
  var mouse = window.matchMedia && window.matchMedia('(hover: hover) and (pointer: fine)').matches;
  if (forced || remembered() || !(wide && mouse)) {
    loadApp();
    return;
  }

  document.getElementById('hm-desktop').className = 'on';
  var note = document.getElementById('hd-note');
  document.getElementById('hd-copy').addEventListener('click', function () {
    var done = function () { note.textContent = 'Link copied. Send it to your phone.'; };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(MOBILE_LINK).then(done, function () { note.textContent = MOBILE_LINK; });
    } else {
      note.textContent = MOBILE_LINK;
    }
  });
  document.getElementById('hd-open').addEventListener('click', function () {
    try { sessionStorage.setItem(KEY, '1'); } catch (e) { /* private mode: still open */ }
    loadApp();
  });
})();
