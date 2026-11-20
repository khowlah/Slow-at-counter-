import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان مستوحاة من الصورة: أخضر القبة، الذهبي، والوردي الفاتح للورود.
class AppColors {
  static const Color domeGreen = Color(0xFF2F5D46);
  static const Color domeGreenDark = Color(0xFF1E3E2F);
  static const Color gold = Color(0xFFC9A24B);
  static const Color rose = Color(0xFFE7A9B6);
  static const Color roseDeep = Color(0xFFD98A9C);
  static const Color cream = Color(0xFFFBF4E9);
  static const Color ink = Color(0xFF2B2620);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.domeGreen,
        primary: AppColors.domeGreen,
        secondary: AppColors.gold,
      ),
      scaffoldBackgroundColor: AppColors.cream,
    );

    final textTheme = GoogleFonts.notoNaskhArabicTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    return base.copyWith(textTheme: textTheme);
  }
}
