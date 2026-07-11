import 'dart:math' as math;
import 'package:flutter/material.dart';

/// MakanKira brand kit — colour tokens, gradients, the logo/wordmark, and the
/// decorative food-and-coin pattern. Everything visual and reusable lives here
/// so the look stays consistent across screens.
///
/// The palette is anchored on a Grab-style vivid green (`makan` = let's eat,
/// go!) warmed with a turmeric-amber accent that stands in for `kira` — the
/// counting / ringgit side of the app.
abstract final class MkColors {
  // Grab-inspired green family.
  static const green = Color(0xFF00B14F); // primary
  static const greenDark = Color(0xFF009543); // pressed / gradient mid
  static const greenDeep = Color(0xFF00713A); // gradient end / on-dark
  static const greenContainer = Color(0xFFC9F0D6); // light tonal fill
  static const greenSurface = Color(0xFFF1FAF3); // faint green-white bg

  // Turmeric amber — the "kira" / money accent. Used sparingly.
  static const amber = Color(0xFFFFB020);
  static const amberDark = Color(0xFFE08A00);

  // Neutrals with a subtle green undertone so they sit with the primary.
  static const ink = Color(0xFF0F1B14); // near-black text
  static const inkSoft = Color(0xFF5B6B60); // secondary text
  static const line = Color(0xFFE4EAE5); // hairline / outline
  static const field = Color(0xFFF1F4F1); // input fill (light)

  // Dark-theme surfaces (deep green-charcoal, not pure black).
  static const darkBg = Color(0xFF0E1512);
  static const darkSurface = Color(0xFF161E1A);
  static const darkField = Color(0xFF1E2723);

  /// The signature diagonal green wash used on heroes, splash, and the logo.
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C259), green, greenDeep],
  );

  static const amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, amberDark],
  );
}

/// Maps a meal-session lifecycle status to a signature colour, so the status
/// pill reads at a glance across the dashboard and detail screens.
Color statusColor(String status) {
  switch (status) {
    case 'collecting_orders':
      return const Color(0xFF2E7CF6); // blue — actively gathering
    case 'finalized':
      return const Color(0xFF009688); // teal — locked in
    case 'bill_entered':
      return MkColors.amber; // amber — money entered
    case 'company_claim_applied':
      return const Color(0xFFEF7C00); // orange — adjusted
    case 'payment_requested':
      return MkColors.green; // green — collecting cash
    case 'closed':
      return const Color(0xFF3E8E5A); // muted green — done
    default:
      return const Color(0xFF8A94A6); // slate — draft
  }
}

/// The MakanKira mark: a rounded-square green tile holding a bowl, with a small
/// amber "RM" coin tucked into the corner — food (`makan`) meets money (`kira`).
///
/// Scales cleanly from an app-bar glyph to a hero. The coin auto-hides at small
/// sizes so it never turns to mush.
class MakanKiraLogo extends StatelessWidget {
  const MakanKiraLogo({super.key, this.size = 72, this.showCoin = true});

  final double size;
  final bool showCoin;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final coin = showCoin && size >= 44;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: MkColors.brandGradient,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: MkColors.green.withValues(alpha: 0.35),
                  blurRadius: size * 0.28,
                  offset: Offset(0, size * 0.12),
                ),
              ],
            ),
            child: Icon(Icons.ramen_dining, color: Colors.white, size: size * 0.56),
          ),
          if (coin)
            Positioned(
              right: -size * 0.06,
              bottom: -size * 0.06,
              child: Container(
                width: size * 0.42,
                height: size * 0.42,
                decoration: BoxDecoration(
                  gradient: MkColors.amberGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: size * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: MkColors.amberDark.withValues(alpha: 0.4),
                      blurRadius: size * 0.1,
                      offset: Offset(0, size * 0.03),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  child: Padding(
                    padding: EdgeInsets.all(size * 0.06),
                    child: const Text(
                      'RM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Two-tone "MakanKira" wordmark. On a green/dark hero pass [onDark] so `Makan`
/// stays white and `Kira` picks up the amber accent; on light surfaces `Makan`
/// is ink and `Kira` is brand green.
class MakanKiraWordmark extends StatelessWidget {
  const MakanKiraWordmark({super.key, this.fontSize = 32, this.onDark = false});

  final double fontSize;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final makan = onDark ? Colors.white : MkColors.ink;
    final kira = onDark ? MkColors.amber : MkColors.green;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Makan', style: TextStyle(color: makan)),
          TextSpan(text: 'Kira', style: TextStyle(color: kira)),
        ],
      ),
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.05,
      ),
    );
  }
}

/// Tonal status pill used on meal cards and the detail hero. Tints itself with
/// the lifecycle [statusColor] so state reads at a glance.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status, required this.label, this.compact = false});

  final String status;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    final fg = Color.lerp(c, Colors.black, 0.22)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint scattered coins/bubbles for hero backgrounds — evokes ringgit coins
/// and steam without competing with the foreground. Deterministic, so it never
/// reshuffles on rebuild.
class FoodPatternPainter extends CustomPainter {
  const FoodPatternPainter({this.color = Colors.white, this.opacity = 0.10});

  final Color color;
  final double opacity;

  // (x, y, radius, ring?) as fractions of the canvas.
  static const _spots = <(double, double, double, bool)>[
    (0.12, 0.18, 0.09, false),
    (0.82, 0.12, 0.06, true),
    (0.68, 0.30, 0.04, false),
    (0.28, 0.42, 0.05, true),
    (0.92, 0.48, 0.10, false),
    (0.06, 0.62, 0.07, true),
    (0.46, 0.70, 0.05, false),
    (0.78, 0.78, 0.08, true),
    (0.20, 0.88, 0.06, false),
    (0.58, 0.94, 0.04, true),
    (0.38, 0.10, 0.03, false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final base = math.min(size.width, size.height);
    for (final (fx, fy, fr, ring) in _spots) {
      final center = Offset(fx * size.width, fy * size.height);
      final r = fr * base;
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = ring ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = r * 0.28;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(FoodPatternPainter old) =>
      old.color != color || old.opacity != opacity;
}
