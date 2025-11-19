import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../constants/onboarding_ui_theme.dart';
import '../widgets/page_indicator.dart';
import 'onboarding_page_one.dart';
import 'onboarding_page_two.dart';
import 'onboarding_page_three.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A1628), // Dark blue background like thansohoc
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top section with page indicator
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: PageIndicator(
                      currentIndex: controller.currentIndex.value,
                      totalPages: OnboardingController.totalPages,
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      onPageChanged: controller.updatePageIndex,
                      children: [
                        _buildPageOne(),
                        const OnboardingPageTwo(),
                        const OnboardingPageThree(),
                      ],
                    ),
                  ),

                  // Bottom section with buttons
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      bottom: 6.h,
                    ),
                    child: _buildBottomSection(),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildPageOne() {
    return Padding(
      padding: OnboardingUITheme.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 80.h),

          // Welcome text
          Text(
            'Chào mừng bạn đến với',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          // App title
          Text(
            'LA BÀN\nPHONG THUỶ',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 60.h),

          // Character illustration from assets
          SizedBox(
            width: 300.w,
            height: 300.h,
            child: Image.asset(
              'assets/compass/onboarding1.png',
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        // Main button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: controller.nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: OnboardingUITheme.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              elevation: 0,
            ),
            child: Text(
              controller.isLastPage ? 'Vào ngay' : 'Tiếp tục',
              style: OnboardingUITheme.buttonTextStyle,
            ),
          ),
        ),

        SizedBox(height: 24.h), // Just spacing, no skip button
      ],
    );
  }
}
