import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0818);
  static const Color backgroundMid = Color(0xFF130F2E);
  static const Color surface = Color(0xFF1C1740);
  static const Color surfaceLight = Color(0xFF252050);

  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFA67CFE);
  static const Color primaryDark = Color(0xFF5E35B1);

  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFEC5C);
  static const Color goldDark = Color(0xFFB8860B);

  static const Color accent = Color(0xFFE040FB);
  static const Color accentBlue = Color(0xFF40C4FF);
  static const Color accentGreen = Color(0xFF00E676);

  static const Color cardMatched = Color(0xFF00E676);
  static const Color cardMismatch = Color(0xFFFF5252);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textGold = Color(0xFFFFD700);

  static const Color timerNormal = Color(0xFF40C4FF);
  static const Color timerWarning = Color(0xFFFFEB3B);
  static const Color timerDanger = Color(0xFFFF5252);

  static const Color starActive = Color(0xFFFFD700);
  static const Color starInactive = Color(0xFF2E2A55);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0818), Color(0xFF1A0E3F), Color(0xFF0A1628)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
  );

  static const LinearGradient cardBackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1740), Color(0xFF2D1B69)],
  );

  static const List<List<Color>> cardGradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
    [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
    [Color(0xFFFD79A8), Color(0xFFE84393)],
    [Color(0xFF00B894), Color(0xFF00CEC9)],
    [Color(0xFF74B9FF), Color(0xFF0984E3)],
    [Color(0xFFE17055), Color(0xFFD63031)],
    [Color(0xFF55EFC4), Color(0xFF00B894)],
    [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
    [Color(0xFFFF7675), Color(0xFFE84393)],
    [Color(0xFFFDCB6E), Color(0xFFE17055)],
    [Color(0xFF81ECEC), Color(0xFF00CEC9)],
    [Color(0xFF6AB04C), Color(0xFF4A9A1A)],
    [Color(0xFFF9CA24), Color(0xFFEB4D4B)],
    [Color(0xFF7ED6DF), Color(0xFF22A6B3)],
    [Color(0xFF58D68D), Color(0xFF27AE60)],
    [Color(0xFF9B59B6), Color(0xFF8E44AD)],
    [Color(0xFF3498DB), Color(0xFF2980B9)],
    [Color(0xFFF39C12), Color(0xFFD68910)],
    [Color(0xFF1ABC9C), Color(0xFF16A085)],
    [Color(0xFFE74C3C), Color(0xFFC0392B)],
    [Color(0xFF2ECC71), Color(0xFF27AE60)],
    [Color(0xFF8E44AD), Color(0xFF6C3483)],
    [Color(0xFFD4AC0D), Color(0xFFB7950B)],
    [Color(0xFF17A589), Color(0xFF148F77)],
    [Color(0xFF884EA0), Color(0xFF76448A)],
    [Color(0xFF1F618D), Color(0xFF1A5276)],
    [Color(0xFFBA4A00), Color(0xFF943126)],
    [Color(0xFF1E8BC3), Color(0xFF1565C0)],
    [Color(0xFF27AE60), Color(0xFF1D8348)],
    [Color(0xFFD35400), Color(0xFFBA4A00)],
  ];
}
