import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/brand.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/language_menu.dart';
import 'google_redirect.dart';

/// Screen 1 — social-login landing. Google sign-in uses a full-page OAuth
/// redirect (popup-free).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
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
                                FilledButton.icon(
                                  onPressed: googleConfigured ? startGoogleSignIn : null,
                                  icon: const _GoogleBadge(),
                                  label: Text(l.continueWithGoogle),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l.termsPrivacy,
                                  textAlign: TextAlign.center,
                                  style: text.bodySmall?.copyWith(color: MkColors.inkSoft),
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

/// A white circle carrying the Google "G", so the green CTA still reads clearly
/// as Google sign-in without shipping the brand asset.
class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Text(
        'G',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFF4285F4),
          fontWeight: FontWeight.w700,
          fontSize: 15,
          height: 1,
        ),
      ),
    );
  }
}
