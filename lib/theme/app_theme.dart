// lib/theme/app_theme.dart
//
// Configuración del tema global de Barro Vivo.
// Utiliza Material Design 3 con la paleta oficial del taller:
//   – Azul cobalto  : #1A53A0
//   – Terracota     : #C1440E
//   – Fondo blanco  : #FAFAFA
//
// Cumple accesibilidad WCAG 2.1 AA:
//   – Botones con altura mínima de 48 dp.
//   – Contraste de texto ≥ 4.5:1.

import 'package:flutter/material.dart';

/// Tokens de color de la identidad visual de Barro Vivo.
class AppColors {
  AppColors._();

  /// Azul cobalto – color primario de la marca.
  static const Color cobaltBlue = Color(0xFF1A53A0);

  /// Terracota – color secundario / acento.
  static const Color terracotta = Color(0xFFC1440E);

  /// Fondo general de la aplicación.
  static const Color background = Color(0xFFFAFAFA);

  /// Superficie de tarjetas y paneles.
  static const Color surface = Color(0xFFFFFFFF);

  /// Texto principal sobre fondo claro.
  static const Color onBackground = Color(0xFF1C1B1F);

  /// Texto sobre el color primario.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Texto sobre el color secundario.
  static const Color onSecondary = Color(0xFFFFFFFF);
}

/// Fábrica del [ThemeData] de la aplicación.
///
/// Uso:
/// ```dart
/// MaterialApp.router(theme: AppTheme.light());
/// ```
class AppTheme {
  AppTheme._();

  /// Tema claro principal de Barro Vivo.
  static ThemeData light() {
    // Esquema de color generado desde la semilla cobalto.
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.cobaltBlue,
      primary: AppColors.cobaltBlue,
      secondary: AppColors.terracotta,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onBackground,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // ── Tipografía ──────────────────────────────────────────────────────
      // Se usa la fuente sans-serif predeterminada del sistema.
      // Para producción puede integrarse Google Fonts (p.ej. "Inter").
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),

      // ── AppBar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cobaltBlue,
        foregroundColor: AppColors.onPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      ),

      // ── ElevatedButton ──────────────────────────────────────────────────
      // Altura mínima de 48 dp para accesibilidad (WCAG 2.1 AA).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cobaltBlue,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── OutlinedButton ──────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cobaltBlue,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.cobaltBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── InputDecoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cobaltBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cobaltBlue.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cobaltBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.terracotta),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cobaltBlue,
        contentTextStyle: TextStyle(color: Colors.white),
      ),

      // ── FloatingActionButton ─────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
      ),
    );
  }
}
