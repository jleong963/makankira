import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'features/auth/google_redirect.dart';
import 'features/auth/oauth.dart';
import 'features/settings/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initOAuth();
  // If we're returning from the Google OAuth redirect, exchange the token for a
  // session cookie before the app (and its auth gate) reads /auth/me.
  await handleGoogleAuthRedirect();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MakanKiraApp(),
    ),
  );
}
