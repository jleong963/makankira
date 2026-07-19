import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/brand.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/agreement_line.dart';
import '../../shared/google_sign_in_button.dart';
import '../../shared/language_menu.dart';
import '../settings/locale_controller.dart';
import 'auth_controller.dart';
import 'google/gis.dart';
import 'session_timeout.dart';

/// OAuth client id compiled in via --dart-define-from-file (the same value the
/// server checks as the ID token audience). Sign-in is inert without it.
const _googleClientId = String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID');

/// GIS button locale; null lets GIS follow the browser language.
String? _gisLocale(Locale? locale) => switch (locale?.languageCode) {
  'en' => 'en',
  'ms' => 'ms',
  'zh' => 'zh_CN',
  _ => null,
};

/// Screen 1 — social-login landing. Sign-in uses the official Google Identity
/// Services (GIS) button: the credential callback yields a Google ID token,
/// which is exchanged for the session cookie via POST /api/auth/login. GIS is
/// initialised with FedCM button UX, so on current browsers the account
/// chooser is native (popup blockers cannot break it).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _termsTap = TapGestureRecognizer();
  final _privacyTap = TapGestureRecognizer();

  // The only Google-branded sign-in control ever shown is the official
  // GIS-rendered button. When GIS is unavailable (VM widget tests, or no
  // compiled-in client id) the branded custom button renders disabled.
  late final bool _useGis = Gis.isSupported && _googleClientId.isNotEmpty;
  bool _gisReady = false;
  bool _gisError = false;

  @override
  void initState() {
    super.initState();
    _termsTap.onTap = () => context.push('/terms');
    _privacyTap.onTap = () => context.push('/privacy');
    if (_useGis) _initGis();
  }

  Future<void> _initGis() async {
    try {
      await Gis.initialize(
        clientId: _googleClientId,
        onCredential: (idToken) {
          if (!mounted) return;
          // Fresh sign-in with no page reload: reset the inactivity clock so
          // the new session is never treated as already stale.
          markSessionActive();
          ref.read(authProvider.notifier).signIn('google', idToken);
        },
      );
      if (mounted) setState(() => _gisReady = true);
    } catch (_) {
      // GIS script failed to load; surface a retry rather than a stuck spinner.
      if (mounted) setState(() => _gisError = true);
    }
  }

  void _retryGis() {
    setState(() {
      _gisError = false;
      _gisReady = false;
    });
    _initGis();
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  /// The sign-in slot of the card: GIS button once ready, a spinner while the
  /// SDK loads, a retry control if it failed, or the disabled branded button
  /// when GIS is unavailable.
  Widget _signInControl(AppLocalizations l) {
    if (!_useGis) {
      return GoogleSignInButton(label: l.continueWithGoogle);
    }
    if (_gisError) {
      return SizedBox(
        height: 44,
        child: Center(
          child: OutlinedButton.icon(
            onPressed: _retryGis,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l.loginError),
          ),
        ),
      );
    }
    if (!_gisReady) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final locale = ref.watch(localeProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        // GIS renders at a fixed pixel width (max 400); fit it to the card.
        final width = constraints.maxWidth.clamp(220.0, 400.0);
        return Center(
          child: Gis.button(
            isDark: Theme.of(context).brightness == Brightness.dark,
            locale: _gisLocale(locale),
            width: width,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    // Shows a message when the last sign-in attempt was rejected (the auth
    // gate returns here with the provider in an error state).
    final authFailed = ref.watch(authProvider).hasError;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [LanguageMenu(), SizedBox(width: 8)],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: MkColors.brandGradient),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: FoodPatternPainter(opacity: 0.08))),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MakanKiraLogo(size: 92),
                        const SizedBox(height: 22),
                        const MakanKiraWordmark(fontSize: 40, onDark: true),
                        const SizedBox(height: 10),
                        Text(
                          l.appTagline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // White action card floating over the green hero.
                        Card(
                          elevation: 12,
                          shadowColor: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l.loginSubtitle,
                                  textAlign: TextAlign.center,
                                  style: text.bodyMedium?.copyWith(color: MkColors.inkSoft),
                                ),
                                const SizedBox(height: 24),
                                if (authFailed) ...[
                                  Text(
                                    l.loginError,
                                    textAlign: TextAlign.center,
                                    style: text.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                _signInControl(l),
                                const SizedBox(height: 16),
                                Text.rich(
                                  agreementSpan(
                                    l: l,
                                    termsRecognizer: _termsTap,
                                    privacyRecognizer: _privacyTap,
                                    base: text.bodySmall?.copyWith(color: MkColors.inkSoft, height: 1.4),
                                    linkStyle: text.bodySmall?.copyWith(
                                      color: MkColors.green,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      height: 1.4,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
