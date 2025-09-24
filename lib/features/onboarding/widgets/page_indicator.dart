import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/onboarding_ui_theme.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: OnboardingUITheme.indicatorSpacing / 2),
          width: index == currentIndex
              ? OnboardingUITheme.indicatorWidth
              : OnboardingUITheme.indicatorHeight * 2,
          height: OnboardingUITheme.indicatorHeight,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? OnboardingUITheme.activeIndicatorColor
                : OnboardingUITheme.inactiveIndicatorColor,
            borderRadius: BorderRadius.circular(OnboardingUITheme.indicatorHeight / 2),
          ),
        ),
      ),
    );
  }
}