import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sistema de espaciado centralizado usando ScreenUtil
/// TODOS los espaciados deben usar estas constantes
class AppSpacing {
  // ===========================
  // ESPACIADO VERTICAL (height)
  // ===========================
  static double get xxs => 2.h;   // 2dp
  static double get xs => 4.h;    // 4dp
  static double get sm => 8.h;    // 8dp
  static double get md => 12.h;   // 12dp
  static double get lg => 16.h;   // 16dp
  static double get xl => 20.h;   // 20dp
  static double get xxl => 24.h;  // 24dp
  static double get huge => 32.h; // 32dp
  static double get massive => 48.h; // 48dp

  // ===========================
  // ESPACIADO HORIZONTAL (width)
  // ===========================
  static double get xxsW => 2.w;
  static double get xsW => 4.w;
  static double get smW => 8.w;
  static double get mdW => 12.w;
  static double get lgW => 16.w;
  static double get xlW => 20.w;
  static double get xxlW => 24.w;
  static double get hugeW => 32.w;
  static double get massiveW => 48.w;

  // ===========================
  // PADDING COMPLETO (EdgeInsets.all)
  // ===========================
  static EdgeInsets get paddingXXS => EdgeInsets.all(xxs);
  static EdgeInsets get paddingXS => EdgeInsets.all(xs);
  static EdgeInsets get paddingSM => EdgeInsets.all(sm);
  static EdgeInsets get paddingMD => EdgeInsets.all(md);
  static EdgeInsets get paddingLG => EdgeInsets.all(lg);
  static EdgeInsets get paddingXL => EdgeInsets.all(xl);
  static EdgeInsets get paddingXXL => EdgeInsets.all(xxl);
  static EdgeInsets get paddingHuge => EdgeInsets.all(huge);

  // ===========================
  // PADDING HORIZONTAL
  // ===========================
  static EdgeInsets get paddingHorizontalXS => EdgeInsets.symmetric(horizontal: xsW);
  static EdgeInsets get paddingHorizontalSM => EdgeInsets.symmetric(horizontal: smW);
  static EdgeInsets get paddingHorizontalMD => EdgeInsets.symmetric(horizontal: mdW);
  static EdgeInsets get paddingHorizontalLG => EdgeInsets.symmetric(horizontal: lgW);
  static EdgeInsets get paddingHorizontalXL => EdgeInsets.symmetric(horizontal: xlW);
  static EdgeInsets get paddingHorizontalXXL => EdgeInsets.symmetric(horizontal: xxlW);

  // ===========================
  // PADDING VERTICAL
  // ===========================
  static EdgeInsets get paddingVerticalXS => EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets get paddingVerticalSM => EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get paddingVerticalMD => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get paddingVerticalLG => EdgeInsets.symmetric(vertical: lg);
  static EdgeInsets get paddingVerticalXL => EdgeInsets.symmetric(vertical: xl);
  static EdgeInsets get paddingVerticalXXL => EdgeInsets.symmetric(vertical: xxl);

  // ===========================
  // RADIUS (para BorderRadius)
  // ===========================
  static double get radiusXS => 4.r;
  static double get radiusSM => 8.r;
  static double get radiusMD => 12.r;
  static double get radiusLG => 16.r;
  static double get radiusXL => 20.r;
  static double get radiusFull => 999.r;

  // BorderRadius completo
  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);
  static BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);
  static BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);
}
