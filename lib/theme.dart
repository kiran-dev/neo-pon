import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//
// extension CustomStyles on TextTheme {
//   TextStyle get error {
//     return TextStyle(
//       fontSize: 18.0,
//       color: Colors.red,
//       fontWeight: FontWeight.bold,
//     );
//   }
// }


class AppTheme {

  static const myColor = HSLColor.fromAHSL(0.5, 120, 0.5, 1);
  static const easyLightBrown = HSLColor.fromAHSL(1, 40, 0.8, 0.57);
  static const coolDarkBlue = HSLColor.fromAHSL(0.6, 180, 1, 0.35);

  static TextTheme lightTextTheme = const TextTheme(
    // Words Card Texts
    displayLarge: TextStyle( // Word Text
      fontSize: 64,
      height: 1.25,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
      color: Colors.black,
    ),
    displaySmall: TextStyle( // NextWord Text
      fontSize: 24,
      // height: 2,
      fontWeight: FontWeight.w400,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineMedium: TextStyle( // Heading Text
      fontSize: 20,
      height: 1.5,
      fontWeight: FontWeight.w800,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineSmall: TextStyle( // "Next Word" Text
      fontSize: 17,
      height: 0.7,
      fontWeight: FontWeight.w700,
      // leadingDistribution: TextLeadingDistribution.proportional,
    ),
    bodyLarge: TextStyle( // Definition Text
        fontSize: 24,
        height: 1.2,
        leadingDistribution: TextLeadingDistribution.even
    ),
    bodySmall: TextStyle( // Qoute Text
      fontSize: 13,
      height: 1.13,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleMedium: TextStyle( // Synonyms , Antonyms
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.2
    ),
    titleSmall: TextStyle( // Tags
        fontWeight: FontWeight.w800,
        fontSize: 18,
        height: 1.15
    ),

    // Vault Screen Texts
    displayMedium: TextStyle( // My Words Heading
        fontWeight: FontWeight.w400,
        fontSize: 32,
        height: 1.5
    ),
    titleLarge: TextStyle( // Group Title Text
        fontWeight: FontWeight.w400,
        fontSize: 24,
        height: 1.5
    ),
    bodyMedium: TextStyle( // DummyContent Text
        fontWeight: FontWeight.w400,
        fontSize: 20,
        height: 1.5
    ),
    labelLarge: TextStyle( // Sort, Group buttons
        fontWeight: FontWeight.w800,
        fontSize: 17,
        height: 1.4
    ),
    labelMedium: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        height: 1.3,
    )
  );

  static TextTheme darkTextTheme = const TextTheme(
    // Words Card Texts
    displayLarge: TextStyle( // Word Text
      fontSize: 64,
      height: 1.5,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
      color: Colors.white,
    ),
    displaySmall: TextStyle( // NextWord Text
      fontSize: 24,
      // height: 2,
      fontWeight: FontWeight.w400,
      leadingDistribution: TextLeadingDistribution.even,
      color: Colors.white,
    ),
    headlineMedium: TextStyle( // Heading Text
      fontSize: 20,
      height: 1.5,
      fontWeight: FontWeight.w800,
      leadingDistribution: TextLeadingDistribution.even,
      color: Colors.white,
    ),
    headlineSmall: TextStyle( // "Next Word" Text
      fontSize: 17,
      height: 0.7,
      fontWeight: FontWeight.w700,
      color: Colors.white
      // leadingDistribution: TextLeadingDistribution.proportional,
    ),
    bodyLarge: TextStyle( // Definition Text
      fontSize: 24,
      height: 1.2,
      leadingDistribution: TextLeadingDistribution.even,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle( // Qoute Text
      fontSize: 13,
      height: 1.13,
      leadingDistribution: TextLeadingDistribution.even,
      color: Colors.white,
    ),
    titleMedium: TextStyle( // Synonyms , Antonyms
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.2,
      color: Colors.white,
    ),
    titleSmall: TextStyle( // Tags
      fontWeight: FontWeight.w800,
      fontSize: 18,
      height: 1.15,
      color: Colors.white,
    ),

    // Vault Screen Texts
    displayMedium: TextStyle( // My Words Heading
      fontWeight: FontWeight.w400,
      fontSize: 32,
      height: 1.5,
      color: Colors.white,
    ),
    titleLarge: TextStyle( // Group Title Text
      fontWeight: FontWeight.w400,
      fontSize: 24,
      height: 1.5,
      color: Colors.white,
    ),
    bodyMedium: TextStyle( // DummyContent Text
      fontWeight: FontWeight.w400,
      fontSize: 20,
      height: 1.5,
      color: Colors.white,
    ),
    labelLarge: TextStyle( // Sort, Group buttons
      fontWeight: FontWeight.w700,
      fontSize: 17,
      height: 1.1,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      height: 1.4,
      color: Colors.white
    )
  );

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith((states) {
          return Colors.black;
        }),
      ),
      textTheme: lightTextTheme,
      primaryColor: Colors.black,
      highlightColor: Colors.white,
      hintColor: Colors.black87,
      shadowColor: const Color.fromARGB(199, 199, 199, 199),
      cardColor: easyLightBrown.toColor(),
      canvasColor: Colors.white70,
      disabledColor: Colors.white54
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: darkTextTheme,
      primaryColor: Colors.white,
      highlightColor: Colors.black,
      hintColor: Colors.white70,
      shadowColor: const Color.fromARGB(84, 84, 84, 84),
      cardColor: coolDarkBlue.toColor(),
      canvasColor: Colors.black87,
      disabledColor: Colors.black45
    );
  }
}
