import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/session_timeout.dart';
import '../features/settings/locale_controller.dart';
import '../features/settings/theme_controller.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

class MakanKiraApp extends ConsumerWidget {
  const MakanKiraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'MakanKira',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Wrap all routed content so inactivity auto-logout applies app-wide.
      builder: (context, child) => InactivityGuard(child: child ?? const SizedBox.shrink()),
      routerConfig: router,
    );
  }
}
