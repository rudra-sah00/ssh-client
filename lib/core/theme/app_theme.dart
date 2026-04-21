import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static const _radius = 16.0;

  static ThemeData get light {
    final base = FlexThemeData.light(
      scheme: FlexScheme.cyanM3,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 4,
      subThemesData: _sub,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
    );
    return base.copyWith(
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _transitions,
    );
  }

  static ThemeData get dark {
    final base = FlexThemeData.dark(
      scheme: FlexScheme.cyanM3,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 12,
      subThemesData: _sub,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
    return base.copyWith(
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _transitions,
    );
  }

  static const _sub = FlexSubThemesData(
    interactionEffects: true,
    blendOnLevel: 20,
    blendOnColors: true,
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
    appBarScrolledUnderElevation: 4,
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
