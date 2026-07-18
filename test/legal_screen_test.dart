import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:makankira/features/legal/legal_document.dart';
import 'package:makankira/features/legal/legal_screen.dart';
import 'package:makankira/features/settings/locale_controller.dart';
import 'package:makankira/l10n/app_localizations.dart';
import 'package:makankira/shared/agreement_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _legalApp(LegalDocKind kind, String languageCode) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      locale: Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LegalScreen(kind: kind),
    ),
  );
}

void main() {
  group('legalDocument data', () {
    test('terms exist in all three languages with the same section count', () {
      final en = legalDocument(LegalDocKind.terms, 'en');
      final ms = legalDocument(LegalDocKind.terms, 'ms');
      final zh = legalDocument(LegalDocKind.terms, 'zh');
      expect(en.sections, hasLength(18));
      expect(ms.sections, hasLength(en.sections.length));
      expect(zh.sections, hasLength(en.sections.length));
      expect(en.title, 'Terms of Service');
      expect(ms.title, 'Terma Perkhidmatan');
      expect(zh.title, '服务条款');
    });

    test('privacy exists in all three languages with the same section count', () {
      final en = legalDocument(LegalDocKind.privacy, 'en');
      final ms = legalDocument(LegalDocKind.privacy, 'ms');
      final zh = legalDocument(LegalDocKind.privacy, 'zh');
      expect(en.sections, hasLength(14));
      expect(ms.sections, hasLength(en.sections.length));
      expect(zh.sections, hasLength(en.sections.length));
      expect(en.title, 'Privacy Policy');
      expect(ms.title, 'Dasar Privasi');
      expect(zh.title, '隐私政策');
    });

    test('every document ends with a contact section carrying the email', () {
      for (final kind in LegalDocKind.values) {
        for (final lang in ['en', 'ms', 'zh']) {
          final doc = legalDocument(kind, lang);
          expect(
            doc.sections.last.blocks.map((b) => b.text).join(),
            contains(kLegalContactEmail),
            reason: '$kind/$lang must list the contact email',
          );
          expect(doc.intro, isNotEmpty, reason: '$kind/$lang has lead paragraphs');
        }
      }
    });

    test('unknown language falls back to English', () {
      expect(legalDocument(LegalDocKind.terms, 'fr').title, 'Terms of Service');
    });
  });

  group('agreement line', () {
    TapGestureRecognizer terms = TapGestureRecognizer();
    TapGestureRecognizer privacy = TapGestureRecognizer();

    setUp(() {
      terms = TapGestureRecognizer();
      privacy = TapGestureRecognizer();
    });

    tearDown(() {
      terms.dispose();
      privacy.dispose();
    });

    (String, List<TextSpan>) render(String languageCode) {
      final l = lookupAppLocalizations(Locale(languageCode));
      final span = agreementSpan(l: l, termsRecognizer: terms, privacyRecognizer: privacy);
      final links = <TextSpan>[];
      span.visitChildren((s) {
        if (s is TextSpan && s.recognizer != null) links.add(s);
        return true;
      });
      return (span.toPlainText(), links);
    }

    test('English wires both links in natural word order', () {
      final (plain, links) = render('en');
      expect(plain, 'By continuing, you agree to our Terms of Service and Privacy Policy.');
      expect(links.map((s) => s.text), ['Terms of Service', 'Privacy Policy']);
      expect(links[0].recognizer, same(terms));
      expect(links[1].recognizer, same(privacy));
    });

    test('Malay wires both links in natural word order', () {
      final (plain, links) = render('ms');
      expect(plain,
          'Dengan meneruskan, anda bersetuju dengan Terma Perkhidmatan dan Dasar Privasi kami.');
      expect(links.map((s) => s.text), ['Terma Perkhidmatan', 'Dasar Privasi']);
      expect(links[0].recognizer, same(terms));
      expect(links[1].recognizer, same(privacy));
    });

    test('Chinese wires both links in natural word order', () {
      final (plain, links) = render('zh');
      expect(plain, '继续即表示您同意我们的服务条款和隐私政策。');
      expect(links.map((s) => s.text), ['服务条款', '隐私政策']);
      expect(links[0].recognizer, same(terms));
      expect(links[1].recognizer, same(privacy));
    });
  });

  group('LegalScreen rendering', () {
    testWidgets('terms render in English', (tester) async {
      await tester.pumpWidget(await _legalApp(LegalDocKind.terms, 'en'));
      expect(find.text('Terms of Service'), findsWidgets); // app bar + heading
      expect(find.text('Last updated: 18 July 2026'), findsOneWidget);
      expect(find.text('1. About the Service'), findsOneWidget);
    });

    testWidgets('terms render in Malay', (tester) async {
      await tester.pumpWidget(await _legalApp(LegalDocKind.terms, 'ms'));
      expect(find.text('Terma Perkhidmatan'), findsWidgets);
      expect(find.text('Kemas kini terakhir: 18 Julai 2026'), findsOneWidget);
      expect(find.text('1. Tentang Perkhidmatan'), findsOneWidget);
    });

    testWidgets('terms render in Chinese', (tester) async {
      await tester.pumpWidget(await _legalApp(LegalDocKind.terms, 'zh'));
      expect(find.text('服务条款'), findsWidgets);
      expect(find.text('最后更新：2026年7月18日'), findsOneWidget);
      expect(find.text('1. 关于本服务'), findsOneWidget);
    });

    testWidgets('privacy renders in all three languages', (tester) async {
      await tester.pumpWidget(await _legalApp(LegalDocKind.privacy, 'en'));
      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.textContaining('Personal Data Protection Act 2010'), findsWidgets);

      await tester.pumpWidget(await _legalApp(LegalDocKind.privacy, 'ms'));
      await tester.pumpAndSettle();
      expect(find.text('Dasar Privasi'), findsWidgets);

      await tester.pumpWidget(await _legalApp(LegalDocKind.privacy, 'zh'));
      await tester.pumpAndSettle();
      expect(find.text('隐私政策'), findsWidgets);
    });

    testWidgets('footer cross-link navigates from terms to privacy', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: '/terms',
        routes: [
          GoRoute(path: '/terms', builder: (_, _) => const LegalScreen(kind: LegalDocKind.terms)),
          GoRoute(path: '/privacy', builder: (_, _) => const LegalScreen(kind: LegalDocKind.privacy)),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final crossLink = find.widgetWithText(TextButton, 'Privacy Policy');
      await tester.scrollUntilVisible(crossLink, 600, scrollable: find.byType(Scrollable).first);
      await tester.tap(crossLink);
      await tester.pumpAndSettle();
      expect(find.text('1. Who we are'), findsOneWidget);

      router.dispose();
    });
  });
}
