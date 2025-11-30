import 'package:flutter/material.dart';

/// Helper centralizado para manejar responsive design
/// TODOS los breakpoints deben verificarse desde aquí
class ResponsiveHelper {
  // ===========================
  // BREAKPOINTS
  // ===========================
  static const double _verySmallBreakpoint = 360;
  static const double _tabletBreakpoint = 600;
  static const double _largeTabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  // ===========================
  // MÉTODOS DE VERIFICACIÓN
  // ===========================
  
  /// Pantallas muy pequeñas (< 360dp)
  /// Ejemplo: Dispositivos Android pequeños
  static bool isVerySmall(BuildContext context) {
    return MediaQuery.of(context).size.width < _verySmallBreakpoint;
  }

  /// Tablet pequeña (>= 600dp)
  /// Ejemplo: Tablets 7", iPad Mini
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= _tabletBreakpoint;
  }

  /// Tablet grande (>= 900dp)
  /// Ejemplo: Tablets 10", iPad Pro
  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= _largeTabletBreakpoint;
  }

  /// Desktop (>= 1200dp)
  /// Ejemplo: Laptops, desktops
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  /// Mobile normal (>= 360dp y < 600dp)
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _verySmallBreakpoint && width < _tabletBreakpoint;
  }

  // ===========================
  // MÉTODOS ÚTILES
  // ===========================
  
  /// Obtiene el ancho de la pantalla
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtiene el alto de la pantalla
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Obtiene el padding seguro del dispositivo (notch, etc)
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Calcula el número de columnas para un grid según el ancho
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int largeTabletColumns = 3,
    int desktopColumns = 4,
  }) {
    if (isDesktop(context)) return desktopColumns;
    if (isLargeTablet(context)) return largeTabletColumns;
    if (isTablet(context)) return tabletColumns;
    return mobileColumns;
  }

  /// Devuelve un valor según el tamaño de pantalla
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? largeTablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isLargeTablet(context) && largeTablet != null) return largeTablet;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Calcula un aspect ratio apropiado para tarjetas según dispositivo
  static double getCardAspectRatio(BuildContext context) {
    if (isVerySmall(context)) return 2.8;
    if (isLargeTablet(context)) return 1.5;
    if (isTablet(context)) return 1.8;
    return 2.5;
  }

  /// Obtiene el tipo de dispositivo como string (para debugging)
  static String getDeviceType(BuildContext context) {
    if (isDesktop(context)) return 'Desktop';
    if (isLargeTablet(context)) return 'Large Tablet';
    if (isTablet(context)) return 'Tablet';
    if (isVerySmall(context)) return 'Very Small Mobile';
    return 'Mobile';
  }
}
