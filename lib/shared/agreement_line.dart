import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Builds the localized "By continuing, you agree to…" line with tappable
/// document links. Placeholders keep each language's own word order: the
/// template is rendered with sentinel characters, which are then swapped for
/// link spans.
TextSpan agreementSpan({
  required AppLocalizations l,
  required GestureRecognizer termsRecognizer,
  required GestureRecognizer privacyRecognizer,
  TextStyle? base,
  TextStyle? linkStyle,
}) {
  final termsToken = String.fromCharCode(0x01);
  final privacyToken = String.fromCharCode(0x02);
  final spans = <InlineSpan>[];
  var rest = l.loginAgreement(termsToken, privacyToken);
  while (rest.isNotEmpty) {
    final indices = [rest.indexOf(termsToken), rest.indexOf(privacyToken)]
      ..removeWhere((i) => i < 0);
    if (indices.isEmpty) {
      spans.add(TextSpan(text: rest));
      break;
    }
    final next = indices.reduce((a, b) => a < b ? a : b);
    if (next > 0) spans.add(TextSpan(text: rest.substring(0, next)));
    final isTerms = rest[next] == termsToken;
    spans.add(TextSpan(
      text: isTerms ? l.termsOfService : l.privacyPolicy,
      style: linkStyle,
      recognizer: isTerms ? termsRecognizer : privacyRecognizer,
    ));
    rest = rest.substring(next + 1);
  }
  return TextSpan(style: base, children: spans);
}
