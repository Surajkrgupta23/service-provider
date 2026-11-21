import 'package:flutter/material.dart';

class AppColors {
  static const Color brandOrange = Color(0xFFFF7A00);
  static const Color brandOrangeDark = Color(0xFFEA580C);
  static const Color brandOrangeRed = Color(0xFFFF4500);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandOrange, brandOrangeRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color bgCream = Color(0xFFFAF5EE);
  static const Color cardWhite = Colors.white;
  static const Color textHeading = Color(0xFF7C2D12);
  static const Color textSubheading = Color(0xFF9A3412);
  static const Color textBody = Color(0xFF374151);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFFED7AA);
  static const Color borderInput = Color(0xFFE5E7EB);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusSuccess = Color(0xFF10B981);
}
