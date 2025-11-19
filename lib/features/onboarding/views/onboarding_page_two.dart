import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/onboarding_ui_theme.dart';

class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: OnboardingUITheme.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30.h),

          // App title
          Text(
            'LA BÀN\nCƠ BẢN',
            style: OnboardingUITheme.titleTextStyle,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: OnboardingUITheme.contentSpacing),

          // Compass illustration from assets
          SizedBox(
            width: 300.w,
            height: 300.h,
            child: Image.asset(
              'assets/compass/onboarding2.png',
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: 40.h),

          // Description
          Text(
            'Giúp bạn xem nhanh hướng\nnhà, hướng đi và ý nghĩa phong\nthuỷ của từng phương',
            style: OnboardingUITheme.descriptionTextStyle,
            textAlign: TextAlign.center,
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
