import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Facebook App ID, compiled in via --dart-define-from-file (config/frontend.*.json).
/// Google uses a full-page redirect flow (see google_redirect.dart) and needs no
/// SDK init here.
const facebookAppId = String.fromEnvironment('FACEBOOK_APP_ID');

/// One-time provider SDK setup. Safe to call with an empty ID.
Future<void> initOAuth() async {
  if (facebookAppId.isNotEmpty) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: facebookAppId,
      cookie: true,
      xfbml: true,
      version: 'v19.0',
    );
  }
}
