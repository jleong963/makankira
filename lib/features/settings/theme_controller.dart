import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_controller.dart'; // sharedPreferencesProvider

const _darkModeKey = 'dark_mode';

/// App theme mode, persisted locally. Defaults to light mode.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final dark = ref.read(sharedPreferencesProvider).getBool(_darkModeKey) ?? false;
    return dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool dark) async {
    await ref.read(sharedPreferencesProvider).setBool(_darkModeKey, dark);
    state = dark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
