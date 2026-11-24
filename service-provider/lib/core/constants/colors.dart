import 'package:flutter/material.dart';

class AppColors {
  static const Color brandOrange = Color(0xFFFF7A00);
  static const Color brandOrangeDark = Color(0xFFEA580C);
  static const Color brandOrangeRed = Color(0xFFFF4800);
  static const Color brandOrangeLight = Color(0xFFFFF7ED);
  static const Color brandOrangeBorder = Color(0xFFFED7AA);

  static const Color brandBlue = Color(0xFF2563EB);
  static const Color brandBlueDark = Color(0xFF1D4ED8);
  static const Color brandBlueLight = Color(0xFFEFF6FF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFFF7A00), Color(0xFFFF4800)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFF7A00), Color(0xFFFF4800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pageBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFEFF6FF),
      Color(0xFFFFFFFF),
      Color(0xFFFFF7ED),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color cardWhite = Colors.white;
  static const Color cardWarm = Color(0xFFFFFDFB);
  static const Color bgSoft = Color(0xFFF8FAFC);
  static const Color bgCream = Color(0xFFFFF7ED);

  static const Color textHeading = Color(0xFF0F172A);
  static const Color textSubheading = Color(0xFF334155);
  static const Color textBody = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderPeach = Color(0xFFFED7AA);
  static const Color borderOrange = Color(0xFFFED7AA);
  static const Color inputBg = Color(0xFFFFFDFB);

  static const Color statusSuccess = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
}
