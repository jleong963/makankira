import 'package:web/web.dart' as web;

/// Browser download / open helpers that synthesize an `<a>` click instead of
/// calling `window.open`. Popup blockers (and embedded/preview contexts)
/// routinely suppress `window.open`, which is what `url_launcher`'s web backend
/// uses — an anchor click is treated as a genuine user navigation and is far
/// more reliable. Downloads happen in place (no popup at all).
void _clickAnchor(void Function(web.HTMLAnchorElement) configure) {
  final a = web.document.createElement('a') as web.HTMLAnchorElement;
  configure(a);
  web.document.body?.appendChild(a);
  a.click();
  a.remove();
}

/// Download the file served at [url] (e.g. an `/api/.../export/*.xlsx`). The
/// server sets `Content-Disposition: attachment`, and for same-origin URLs the
/// empty `download` attribute lets that filename win — the browser saves the
/// file rather than navigating away.
void downloadUrl(String url) {
  _clickAnchor((a) {
    a.href = url;
    a.rel = 'noopener';
    a.download = '';
  });
}

/// Open [url] in a new tab (e.g. a `wa.me` click-to-chat link).
void openUrl(String url) {
  _clickAnchor((a) {
    a.href = url;
    a.target = '_blank';
    a.rel = 'noopener noreferrer';
  });
}
