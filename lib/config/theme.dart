import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.black, // Monochrome
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.light,
        surface: Colors.white,
        primary: Colors.black,
        secondary: Colors.grey[800],
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: const TextStyle(color: Colors.black),
        bodyMedium: const TextStyle(color: Colors.black87),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Softer corners
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ), // Subtle border
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ), // Tighter margin
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0, // Flat button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ), // Less rounded
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.black),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFA), // Very light grey
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
        labelStyle: const TextStyle(color: Colors.black54),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Colors.black12,
        selectionHandleColor: Colors.black,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.white, // Monochrome Dark
      scaffoldBackgroundColor: const Color(0xFF000000), // True Black
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
        surface: const Color(0xFF121212), // Dark Grey for Cards/Sheets
        primary: Colors.white,
        secondary: Colors.grey[200],
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(
          0xFF000000,
        ), // Post background usually black in dark mode
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Full width often
          side: BorderSide(color: Colors.grey.shade900, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF000000),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White button in dark mode
          foregroundColor: Colors.black, // Black text
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF262626), // Dark Grey
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white24,
        selectionHandleColor: Colors.white,
      ),
    );
  }
}
