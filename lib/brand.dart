import 'package:flutter/material.dart';

class RiverTechBrand {
  static const appName = 'RiverTech Client';
  static const gatewayName = 'RiverTech Gateway';
  static const supportEmail = 'support@rivertech.com';

  static const deepWater = Color(0xFF102870);
  static const harborBlue = Color(0xFF1038B0);
  static const signalBlue = Color(0xFF3860D8);
  static const mist = Color(0xFFEAF1FF);
  static const ice = Color(0xFFF7FAFF);
  static const accent = Color(0xFF6F8BFF);

  static ThemeData theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: signalBlue,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? mist : harborBlue,
      secondary: signalBlue,
      tertiary: accent,
      surface: isDark ? const Color(0xFF081A4A) : ice,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? const Color(0xFF0C205C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFDDE6FF),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return signalBlue;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return signalBlue.withValues(alpha: 0.35);
          }
          return null;
        }),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
