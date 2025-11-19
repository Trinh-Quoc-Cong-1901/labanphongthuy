import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/onboarding_ui_theme.dart';

class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({super.key});

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
            'LA BÀN\nTHEO TUỔI',
            style: OnboardingUITheme.titleTextStyle,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: OnboardingUITheme.contentSpacing),

          // Zodiac compass illustration from assets
          SizedBox(
            width: 300.w,
            height: 300.h,
            child: Image.asset(
              'assets/compass/onboarding3.png',
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: OnboardingUITheme.contentSpacing),

          // Description
          Text(
            'Tìm hướng hợp tuổi,\ntránh hướng xấu, nâng cao vận khí',
            style: OnboardingUITheme.descriptionTextStyle,
            textAlign: TextAlign.center,
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
