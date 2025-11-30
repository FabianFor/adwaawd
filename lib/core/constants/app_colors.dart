import 'package:flutter/material.dart';

/// Sistema de colores centralizado para toda la aplicación
/// Todos los colores deben usarse desde aquí para mantener consistencia
class AppColors {
  // ===========================
  // COLORES PRIMARIOS
  // ===========================
  static const primary = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF1976D2);
  static const primaryLight = Color(0xFF42A5F5);

  // ===========================
  // COLORES DE ESTADO
  // ===========================
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFF66BB6A);
  static const successDark = Color(0xFF388E3C);

  static const warning = Color(0xFFFF9800);
  static const warningLight = Color(0xFFFFB74D);
  static const warningDark = Color(0xFFF57C00);

  static const error = Color(0xFFF44336);
  static const errorLight = Color(0xFFE57373);
  static const errorDark = Color(0xFFD32F2F);

  static const info = Color(0xFF607D8B);
  static const infoLight = Color(0xFF78909C);
  static const infoDark = Color(0xFF455A64);

  // ===========================
  // COLORES NEUTROS
  // ===========================
  static const backgroundLight = Color(0xFFF5F5F5);
  static const backgroundDark = Color(0xFF121212);
  
  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF1E1E1E);

  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFF9E9E9E);
  static const textLight = Colors.white;

  static final borderLight = Colors.grey[300]!;
  static final borderDark = Colors.grey[700]!;

  static final dividerLight = Colors.grey[200]!;
  static final dividerDark = Colors.grey[800]!;

  // ===========================
  // COLORES CON OPACIDAD
  // ===========================
  static Color primaryWithOpacity(double opacity) => 
      primary.withOpacity(opacity);
  
  static Color successWithOpacity(double opacity) => 
      success.withOpacity(opacity);
  
  static Color warningWithOpacity(double opacity) => 
      warning.withOpacity(opacity);
  
  static Color errorWithOpacity(double opacity) => 
      error.withOpacity(opacity);
  
  static Color infoWithOpacity(double opacity) => 
      info.withOpacity(opacity);

  // ===========================
  // COLORES PARA GRADIENTES
  // ===========================
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFF57C00),
  ];

  // ===========================
  // COLORES PARA TARJETAS DE ESTADÍSTICAS
  // ===========================
  static const cardProductsColor = Color(0xFF4CAF50);
  static const cardOrdersColor = Color(0xFF2196F3);
  static const cardInvoicesColor = Color(0xFFFF9800);
  static const cardRevenueColor = Color(0xFF9C27B0);
}
