import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/onboarding_ui_theme.dart';

class OnboardingPageOne extends StatelessWidget {
  const OnboardingPageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: OnboardingUITheme.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60.h),

          // Welcome text
          Text(
            'Chào mừng bạn đến với',
            style: OnboardingUITheme.descriptionTextStyle,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // App title
          Text(
            'LA BÀN\nPHONG THUỶ',
            style: OnboardingUITheme.titleTextStyle,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: OnboardingUITheme.contentSpacing),

          // Character illustration from assets
          Container(
            width: 280.w,
            height: 280.h,
            child: Image.asset(
              'assets/compass/onboarding1.png',
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: OnboardingUITheme.contentSpacing),

          const Spacer(),
        ],
      ),
    );
  }
}
