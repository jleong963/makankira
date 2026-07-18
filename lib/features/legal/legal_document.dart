import 'privacy_content.dart';
import 'terms_content.dart';

/// Contact address shown on the legal pages (Terms §18, Privacy §14).
/// Change it here if the service ever moves to a dedicated inbox.
const kLegalContactEmail = 'deskcontact5@gmail.com';

/// Which legal document a route/screen shows.
enum LegalDocKind { terms, privacy }

/// One localized legal document, ready to render.
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.updated,
    required this.intro,
    required this.sections,
  });

  final String title;

  /// Localized "Last updated: …" line.
  final String updated;

  /// Lead paragraphs shown before the first numbered section.
  final List<String> intro;

  final List<LegalSection> sections;
}

class LegalSection {
  const LegalSection(this.heading, this.blocks);

  final String heading;
  final List<LegalBlock> blocks;
}

/// A paragraph or a bulleted line within a section.
class LegalBlock {
  const LegalBlock.p(this.text) : bullet = false;
  const LegalBlock.li(this.text) : bullet = true;

  final String text;
  final bool bullet;
}

/// Returns the document for [kind] in the app language ([languageCode] is one
/// of en/zh/ms, mirroring the supported locales).
LegalDocument legalDocument(LegalDocKind kind, String languageCode) {
  switch (kind) {
    case LegalDocKind.terms:
      switch (languageCode) {
        case 'ms':
          return termsMs();
        case 'zh':
          return termsZh();
        default:
          return termsEn();
      }
    case LegalDocKind.privacy:
      switch (languageCode) {
        case 'ms':
          return privacyMs();
        case 'zh':
          return privacyZh();
        default:
          return privacyEn();
      }
  }
}
