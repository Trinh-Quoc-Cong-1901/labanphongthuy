import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SplashController when splash view is created (like thansohoc)
    Get.find<SplashController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628), // Same as app background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Logo
            Container(
              width: 200.w,
              height: 200.h,
              child: Image.asset(
                'assets/icon/logo_app.png',
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 32.h),

            const Spacer(),

            // Loading indicator
            Container(
              margin: EdgeInsets.only(bottom: 60.h),
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFDC24C), // Golden color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}