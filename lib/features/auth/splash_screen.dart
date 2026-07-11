import 'package:flutter/material.dart';
import '../../app/brand.dart';
import '../../l10n/app_localizations.dart';

/// Shown only while the session check (`/auth/me`) is in flight, so neither the
/// dashboard nor the login form flashes before we know whether the user is
/// signed in. The router replaces it with /login or the destination once the
/// check resolves.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: MkColors.brandGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: FoodPatternPainter(opacity: 0.08)),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MakanKiraLogo(size: 104),
                  const SizedBox(height: 28),
                  const MakanKiraWordmark(fontSize: 40, onDark: true),
                  const SizedBox(height: 10),
                  Text(
                    l.appTagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
