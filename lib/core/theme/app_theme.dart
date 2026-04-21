import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static const _radius = 16.0;
  static const _accent = Color(0xFFB0B0B0);

  static ThemeData get light => dark;

  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: _accent,
        primaryContainer: Color(0xFF2A2A2A),
        secondary: Color(0xFF8E8E8E),
        secondaryContainer: Color(0xFF222222),
        tertiary: Color(0xFF9E9E9E),
        tertiaryContainer: Color(0xFF1E1E1E),
      ),
      darkIsTrueBlack: true,
      surfaceMode: FlexSurfaceMode.level,
      blendLevel: 0,
      subThemesData: _sub,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
    return base.copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: base.colorScheme.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerHighest: const Color(0xFF1A1A1A),
        surfaceContainerHigh: const Color(0xFF141414),
        surfaceContainer: const Color(0xFF0F0F0F),
        surfaceContainerLow: const Color(0xFF0A0A0A),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: const Color(0xFF0F0F0F),
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: const Color(0xFF111111),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: const Color(0xFF111111),
      ),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _transitions,
    );
  }

  static const _sub = FlexSubThemesData(
    interactionEffects: true,
    blendOnLevel: 0,
    blendOnColors: false,
    defaultRadius: _radius,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: _radius,
    inputDecoratorUnfocusedHasBorder: true,
    inputDecoratorFocusedHasBorder: true,
    inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
    fabRadius: 20,
    fabSchemeColor: SchemeColor.primary,
    chipRadius: 10,
    cardRadius: _radius,
    dialogRadius: 24,
    appBarCenterTitle: true,
    appBarScrolledUnderElevation: 0,
    navigationBarIndicatorSchemeColor: SchemeColor.primary,
    bottomSheetRadius: 24,
    snackBarRadius: 12,
    snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
  );

  static const _transitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  static String get terminalFontFamily =>
      GoogleFonts.jetBrainsMono().fontFamily ?? 'monospace';

  static TextStyle get terminalStyle => GoogleFonts.jetBrainsMono(fontSize: 14);
}
