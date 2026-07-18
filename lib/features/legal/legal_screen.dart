import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/language_menu.dart';
import 'legal_document.dart';

/// Public legal page (/terms and /privacy). Reachable without signing in, so
/// people can read what they're agreeing to *before* the Google button — and
/// so the URLs can be listed on the Google OAuth consent screen.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});

  final LegalDocKind kind;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final doc = legalDocument(kind, Localizations.localeOf(context).languageCode);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final otherIsTerms = kind == LegalDocKind.privacy;
    final otherLabel = otherIsTerms ? l.termsOfService : l.privacyPolicy;
    final otherPath = otherIsTerms ? '/terms' : '/privacy';

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.title),
        // A deep link straight to /terms has no page to pop back to; fall back
        // to home (which the auth gate turns into /login when signed out).
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: const [LanguageMenu(), SizedBox(width: 8)],
      ),
      body: SelectionArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              children: [
                Text(doc.title, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  doc.updated,
                  style: text.labelMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (final paragraph in doc.intro) ...[
                  Text(paragraph, style: text.bodyLarge?.copyWith(height: 1.55)),
                  const SizedBox(height: 10),
                ],
                for (final section in doc.sections) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 22, bottom: 8),
                    child: Text(
                      section.heading,
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final block in section.blocks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: block.bullet
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 10),
                                  child: Text('•', style: text.bodyMedium?.copyWith(height: 1.55)),
                                ),
                                Expanded(
                                  child: Text(block.text, style: text.bodyMedium?.copyWith(height: 1.55)),
                                ),
                              ],
                            )
                          : Text(block.text, style: text.bodyMedium?.copyWith(height: 1.55)),
                    ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push(otherPath),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: Text(otherLabel),
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
