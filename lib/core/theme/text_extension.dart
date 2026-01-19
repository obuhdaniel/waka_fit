import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

extension CustomTextStyles on TextTheme {
  TextStyle get myTextStyle => TextStyle(
        fontSize: 13.0.sp,
      );

  TextStyle get myRegularStyle => TextStyle(
      fontSize: 13.0.sp, color: AppColors.green, fontWeight: FontWeight.w400);

  TextStyle get myRegularStyle1 => TextStyle(
      fontSize: 13.0.sp, color: AppColors.black, fontWeight: FontWeight.w700);

  TextStyle get myRegularStyle7 =>
      TextStyle(fontSize: 13.0.sp, fontWeight: FontWeight.w400);

  TextStyle get myRegularStyle5 => TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: AppColors.darkGreen,
      );

  TextStyle get myRegularStyle6 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: AppColors.darkGreen,
      );

  TextStyle get mybodyStyle =>
      TextStyle(fontSize: 14.0.sp, fontWeight: FontWeight.w400);

  TextStyle get myBodyStyle1 => TextStyle(
      fontSize: 12.0.sp, color: AppColors.white, fontWeight: FontWeight.w400);

  TextStyle get myRegularStyle4 => TextStyle(
      fontSize: 12.0.sp, color: AppColors.white, fontWeight: FontWeight.w700);

  TextStyle get myRegularStyle2 => TextStyle(
      fontSize: 14.0.sp,
      color: AppColors.darkGreen,
      fontWeight: FontWeight.w400);

  TextStyle get myRegularStyle3 =>
      TextStyle(fontSize: 14.0.sp, fontWeight: FontWeight.w700);

  TextStyle get myTitleStyle =>
      TextStyle(fontSize: 16.0.sp, fontWeight: FontWeight.w700);

  TextStyle get myTitleStyle1 =>
      TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700);

  TextStyle get myTitleStyle2 => TextStyle(
      fontSize: 24.0.sp, color: AppColors.white, fontWeight: FontWeight.w700);

  TextStyle get myTitleStyle3 => TextStyle(
      fontSize: 33.0.sp, color: AppColors.white, fontWeight: FontWeight.w700);
}
