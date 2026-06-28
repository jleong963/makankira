import 'dart:convert';
import 'dart:math';
import 'package:web/web.dart' as web;
import '../../api/api_client.dart';

/// Popup-free Google sign-in via a full-page OAuth 2.0 / OpenID Connect redirect
/// (`response_type=id_token`). Unlike the GIS button it never opens a popup, so
/// it works even when popups are blocked or the app runs in an embedded context.
///
/// Flow:
///   1. [startGoogleSignIn] navigates the whole page to Google's auth endpoint.
///   2. Google authenticates the user and redirects back to the app origin with
///      `#id_token=<JWT>&state=<state>` in the URL fragment.
///   3. [handleGoogleAuthRedirect] (called from main() before runApp) verifies
///      state + nonce, POSTs the token to /api/auth/login to mint the session
///      cookie, then strips the fragment so the hash router starts clean.

const _googleClientId = String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID');
const _authEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
const _stateKey = 'mk_g_oauth_state';
const _nonceKey = 'mk_g_oauth_nonce';

/// Whether a Google client ID was compiled in (sign-in is inert without it).
bool get googleConfigured => _googleClientId.isNotEmpty;

/// Registered redirect URI: the app origin root. Must be listed under
/// "Authorized redirect URIs" for this OAuth client in Google Cloud Console.
String _redirectUri() => '${web.window.location.origin}/';

String _randomToken() {
  final rnd = Random.secure();
  return base64UrlEncode(List<int>.generate(32, (_) => rnd.nextInt(256))).replaceAll('=', '');
}

/// Begin sign-in. Triggered by a direct button tap — a full-page navigation,
/// so there is no popup for a blocker to intercept.
void startGoogleSignIn() {
  if (!googleConfigured) return;
  final state = _randomToken();
  final nonce = _randomToken();
  web.window.sessionStorage.setItem(_stateKey, state);
  web.window.sessionStorage.setItem(_nonceKey, nonce);
  final url = Uri.parse(_authEndpoint).replace(queryParameters: <String, String>{
    'client_id': _googleClientId,
    'redirect_uri': _redirectUri(),
    'response_type': 'id_token',
    'scope': 'openid email profile',
    'nonce': nonce,
    'state': state,
    'prompt': 'select_account',
  });
  web.window.location.assign(url.toString());
}

/// If the current URL is an OAuth callback (token in the fragment), complete
/// sign-in: verify state + nonce, exchange the token for a session cookie, and
/// strip the fragment. Returns true when a callback was present. Safe to call on
/// every startup.
Future<bool> handleGoogleAuthRedirect() async {
  final hash = web.window.location.hash;
  final frag = hash.startsWith('#') ? hash.substring(1) : hash;
  if (!frag.contains('id_token=') && !frag.contains('error=')) return false;

  final params = Uri.splitQueryString(frag);
  final expectedState = web.window.sessionStorage.getItem(_stateKey);
  final expectedNonce = web.window.sessionStorage.getItem(_nonceKey);
  web.window.sessionStorage.removeItem(_stateKey);
  web.window.sessionStorage.removeItem(_nonceKey);

  // Always strip the OAuth fragment so the (hash-based) router starts clean and
  // the token does not linger in the URL or history.
  final loc = web.window.location;
  web.window.history.replaceState(null, '', '${loc.pathname}${loc.search}');

  if (params['error'] != null) return true; // user denied / provider error

  final idToken = params['id_token'];
  final state = params['state'];
  // CSRF: the returned state must match the one we stored before redirecting.
  if (idToken == null || state == null || expectedState == null || state != expectedState) {
    return true;
  }
  // Replay defense: the nonce we issued must be echoed inside the ID token.
  if (expectedNonce != null && _jwtNonce(idToken) != expectedNonce) return true;

  try {
    await ApiClient().postJson('/auth/login', body: {'provider': 'google', 'credential': idToken});
  } catch (_) {
    // Token rejected or network error: stay signed out; the login screen shows.
  }
  return true;
}

/// Read the (unverified) `nonce` claim from a JWT payload. The signature is
/// verified server-side by /api/auth/login; here we only confirm the token
/// carries the nonce we just issued.
String? _jwtNonce(String jwt) {
  final parts = jwt.split('.');
  if (parts.length < 2) return null;
  try {
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    return payload is Map && payload['nonce'] is String ? payload['nonce'] as String : null;
  } catch (_) {
    return null;
  }
}
