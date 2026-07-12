import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// The official multicolor Google "G" logo (unmodified — required by Google's
/// branding guidelines; it must not be recolored, resized disproportionately,
/// or replaced with a custom icon).
const String _googleGSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>''';

/// Parsed once (synchronous; the logo has no embedded raster images).
final ScalableImage _googleG = ScalableImage.fromSvgString(_googleGSvg, warnF: (_) {});

/// A "Sign in with Google" button that follows Google's official branding
/// guidelines: the unmodified multicolor "G", light/dark surface + 1px stroke,
/// 14px medium label, 40px height, 4px radius. [label] must be one of the
/// approved strings ("Sign in with Google" / "Sign up with Google" /
/// "Continue with Google"). Disabled when [onPressed] is null.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Exact spec values from developers.google.com/identity/branding-guidelines.
    final fill = dark ? const Color(0xFF131314) : const Color(0xFFFFFFFF);
    final stroke = dark ? const Color(0xFF8E918F) : const Color(0xFF747775);
    final textColor = dark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);
    final enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: stroke),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 18, height: 18, child: ScalableImageWidget(si: _googleG)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      // Google's spec is Roboto/Google Sans Medium — not the app's
                      // brand font (Poppins). Flutter web (CanvasKit) bundles
                      // Roboto; elsewhere it falls back to a neutral sans-serif.
                      fontFamily: 'Roboto',
                      fontFamilyFallback: const ['Arial', 'Helvetica', 'sans-serif'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
