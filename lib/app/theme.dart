import 'package:flutter/material.dart';
import 'brand.dart';

/// MakanKira theme — a Grab-style vivid green, Poppins typography, and soft
/// rounded surfaces. Component themes here restyle every screen at once, so
/// individual widgets only need custom layout, not custom styling.
///
/// Pass [brightness] to build the matching light or dark variant.
ThemeData buildTheme([Brightness brightness = Brightness.light]) {
  final dark = brightness == Brightness.dark;

  final scheme = ColorScheme.fromSeed(
    seedColor: MkColors.green,
    brightness: brightness,
  ).copyWith(
    primary: dark ? const Color(0xFF1BC167) : MkColors.green,
    onPrimary: dark ? MkColors.ink : Colors.white,
    primaryContainer: dark ? MkColors.greenDeep : MkColors.greenContainer,
    onPrimaryContainer: dark ? MkColors.greenContainer : MkColors.greenDeep,
    secondary: MkColors.amber,
    onSecondary: MkColors.ink,
    tertiary: MkColors.amber,
    onTertiary: MkColors.ink,
    surface: dark ? MkColors.darkSurface : Colors.white,
    onSurface: dark ? const Color(0xFFE6EDE8) : MkColors.ink,
    onSurfaceVariant: dark ? const Color(0xFFA8B4AC) : MkColors.inkSoft,
    outline: dark ? const Color(0xFF33413A) : MkColors.line,
    outlineVariant: dark ? const Color(0xFF283029) : const Color(0xFFEDF1ED),
  );

  final baseText = (dark ? Typography.material2021().white : Typography.material2021().black)
      .apply(fontFamily: 'Poppins');
  final textTheme = baseText.copyWith(
    displaySmall: baseText.displaySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
    headlineMedium: baseText.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
    headlineSmall: baseText.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
    titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: baseText.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: baseText.bodyLarge?.copyWith(height: 1.35),
    bodyMedium: baseText.bodyMedium?.copyWith(height: 1.35),
    labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
  );

  final scaffoldBg = dark ? MkColors.darkBg : MkColors.greenSurface;
  final fieldFill = dark ? MkColors.darkField : MkColors.field;

  OutlineInputBorder inputBorder(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  ButtonStyle bigButton(ButtonStyle base) => base.copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Poppins', fontSize: 15.5, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 22)),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffoldBg,
    fontFamily: 'Poppins',
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBg,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black26,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: dark ? Colors.black54 : const Color(0x140F1B14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: inputBorder(Colors.transparent, 0),
      enabledBorder: inputBorder(Colors.transparent, 0),
      focusedBorder: inputBorder(scheme.primary, 1.6),
      errorBorder: inputBorder(scheme.error, 1.2),
      focusedErrorBorder: inputBorder(scheme.error, 1.6),
    ),
    filledButtonTheme: FilledButtonThemeData(style: bigButton(FilledButton.styleFrom())),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: bigButton(ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      )),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: bigButton(OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.5), width: 1.4),
      )),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 3,
      focusElevation: 3,
      hoverElevation: 4,
      extendedTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: dark ? MkColors.darkField : MkColors.greenSurface,
      selectedColor: scheme.primaryContainer,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12.5, color: scheme.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: scheme.primary,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: MkColors.ink,
      contentTextStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
  );
}
