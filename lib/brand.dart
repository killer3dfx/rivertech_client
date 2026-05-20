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
    final scheme =
        ColorScheme.fromSeed(
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
        backgroundColor: scheme.surface,
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

class RiverTechMark extends StatelessWidget {
  const RiverTechMark({
    super.key,
    this.size = 44,
    this.backgroundColor = Colors.white,
    this.foregroundColor = RiverTechBrand.signalBlue,
    this.accentColor = RiverTechBrand.deepWater,
  });

  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _RiverTechMarkPainter(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        accentColor: accentColor,
      ),
    );
  }
}

class _RiverTechMarkPainter extends CustomPainter {
  const _RiverTechMarkPainter({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.accentColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.width * 0.2;
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      backgroundPaint,
    );

    final wavePaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round;

    final wave = Path()
      ..moveTo(size.width * 0.18, size.height * 0.64)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.38,
        size.width * 0.56,
        size.height * 0.72,
        size.width * 0.82,
        size.height * 0.42,
      );
    canvas.drawPath(wave, wavePaint);

    final nodePaint = Paint()..color = accentColor;
    canvas.drawCircle(
      Offset(size.width * 0.34, size.height * 0.43),
      size.width * 0.105,
      nodePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.58),
      size.width * 0.085,
      nodePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RiverTechMarkPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.accentColor != accentColor;
  }
}
