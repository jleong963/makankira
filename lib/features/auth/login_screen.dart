import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/language_menu.dart';
import 'auth_controller.dart';
import 'google_redirect.dart';

/// Screen 1 — social-login landing. Google is primary (full-page OAuth redirect,
/// popup-free); Facebook is secondary.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Future<void> _facebook() async {
    final l = AppLocalizations.of(context);
    try {
      final result = await FacebookAuth.instance.login();
      final token = result.accessToken;
      if (result.status == LoginStatus.success && token != null) {
        await ref.read(authProvider.notifier).signIn('facebook', token.tokenString);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.loginError)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(actions: const [LanguageMenu(), SizedBox(width: 8)]),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.ramen_dining, size: 64),
                  const SizedBox(height: 16),
                  Text(l.appName, textAlign: TextAlign.center, style: text.displaySmall),
                  const SizedBox(height: 8),
                  Text(l.appTagline, textAlign: TextAlign.center, style: text.titleMedium),
                  const SizedBox(height: 16),
                  Text(l.loginSubtitle, textAlign: TextAlign.center, style: text.bodyMedium),
                  const SizedBox(height: 32),
                  // Full-page redirect to Google (no popup, so popup blockers and
                  // embedded contexts can't break it).
                  FilledButton.icon(
                    onPressed: googleConfigured ? startGoogleSignIn : null,
                    icon: const Icon(Icons.login),
                    label: Text(l.continueWithGoogle),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _facebook,
                    icon: const Icon(Icons.facebook),
                    label: Text(l.continueWithFacebook),
                  ),
                  const SizedBox(height: 24),
                  Text(l.termsPrivacy, textAlign: TextAlign.center, style: text.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
