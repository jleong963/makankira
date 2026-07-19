import 'package:flutter/widgets.dart';

// Web implementation is selected only when compiling for the web (JS or wasm —
// the implementation uses package:web/dart:js_interop, so `js_interop` is the
// correct condition; `dart.library.html` would be false under --wasm and
// silently disable real sign-in). VM widget tests and any non-web target use
// the no-op stub.
import 'gis_stub.dart' if (dart.library.js_interop) 'gis_web.dart' as impl;

/// Thin facade over the Google Identity Services (GIS) SDK.
///
/// The GIS-rendered button is the sign-in control because it always follows
/// Google's current branding guideline. The sign-in callback yields a Google
/// **ID token** (a JWT) which the app exchanges for its HttpOnly session
/// cookie via `POST /api/auth/login` (the server verifies the token against
/// Google's JWKS).
class Gis {
  const Gis._();

  /// Whether real GIS is available on this platform (web only).
  static bool get isSupported => impl.gisIsSupported;

  /// Loads GIS (if needed) and initialises it with the OAuth [clientId].
  /// [onCredential] is invoked with the Google ID token on successful sign-in.
  static Future<void> initialize({
    required String clientId,
    required void Function(String idToken) onCredential,
  }) => impl.gisInitialize(clientId: clientId, onCredential: onCredential);

  /// The official GIS button rendered into a platform view.
  static Widget button({
    required bool isDark,
    String? locale,
    double width = 320,
  }) => impl.gisButton(isDark: isDark, locale: locale, width: width);

  /// Clears GIS auto-select so the next sign-in shows the account chooser
  /// instead of silently reusing the previous account.
  static void signOut() => impl.gisSignOut();
}
