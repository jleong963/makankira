import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Web Push public key, compiled in via --dart-define-from-file (safe to ship).
const vapidPublicKey = String.fromEnvironment('VAPID_PUBLIC_KEY');

/// Registers the push service worker, requests permission, and subscribes.
/// Returns the subscription as {endpoint, p256dh, auth, userAgent}, or null if
/// unavailable/denied. Android + desktop browsers only (not iOS).
Future<Map<String, dynamic>?> subscribeWebPush() async {
  if (vapidPublicKey.isEmpty) return null;

  final registration = await web.window.navigator.serviceWorker.register('push_sw.js'.toJS).toDart;
  final permission = (await web.Notification.requestPermission().toDart).toDart;
  if (permission != 'granted') return null;

  final options = web.PushSubscriptionOptionsInit(
    userVisibleOnly: true,
    applicationServerKey: vapidPublicKey.toJS,
  );
  final subscription = await registration.pushManager.subscribe(options).toDart;

  final decoded = (subscription.toJSON() as JSObject).dartify();
  if (decoded is! Map) return null;
  final map = decoded.cast<String, dynamic>();
  final keys = (map['keys'] as Map?)?.cast<String, dynamic>();
  final endpoint = map['endpoint'] as String?;
  if (endpoint == null || keys == null) return null;

  return {
    'endpoint': endpoint,
    'p256dh': keys['p256dh'],
    'auth': keys['auth'],
    'userAgent': web.window.navigator.userAgent,
  };
}

/// Best-effort foreground system notification, shown while the app is open (e.g.
/// the tab is backgrounded). Uses the permission the user already granted via
/// [subscribeWebPush]; it never prompts and is a no-op when notifications are
/// unavailable or not permitted. The in-app SnackBar is the reliable fallback.
void showLocalNotification(String title, String body) {
  try {
    if (web.Notification.permission != 'granted') return;
    web.Notification(
      title,
      web.NotificationOptions(body: body, icon: 'icons/Icon-192.png', badge: 'icons/Icon-192.png'),
    );
  } catch (_) {
    // Ignore — the caller also shows an in-app SnackBar, which always works.
  }
}

/// Whether the page is currently hidden (backgrounded tab / minimized window).
/// Lets the caller skip a system notification when the app is on-screen and an
/// in-app banner already suffices. Defaults to false if the API is unavailable.
bool pageIsHidden() {
  try {
    return web.document.hidden;
  } catch (_) {
    return false;
  }
}
