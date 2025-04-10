import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// Tema para o modo claro
  static ThemeData get lightTheme {
    return ThemeData(
      // Cor primária da aplicação
      primaryColor: AppColors.pink,

      // Define o esquema de cores com base nas constantes
      colorScheme: ColorScheme(
        primary: AppColors.pink,
        surface: AppColors.webNeutral200,
        error: AppColors.error,
        brightness: Brightness.light,
        secondary: AppColors.webNeutral200,
        onPrimary: AppColors.white,
        onSecondary: AppColors.pink,
        onError: AppColors.white,
        onSurface: AppColors.webNeutral900,
      ),

      // Configuração das fontes e cores dos textos
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.primaryDark),
        bodyMedium: TextStyle(color: AppColors.secondaryDark),
        bodySmall: TextStyle(color: AppColors.tertiaryDark),
      ),

      // Outras configurações podem ser adicionadas aqui (botões, ícones, etc.)
    );
  }
}
