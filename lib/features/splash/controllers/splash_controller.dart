import 'dart:async';
import 'package:get/get.dart';
import '../../../services/onboarding_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    try {
      // Minimum splash duration like thansohoc
      await Future.delayed(const Duration(milliseconds: 1000));

      // Progressive navigation logic like thansohoc
      final isOnboardingCompleted =
          await OnboardingService.isOnboardingCompleted();

      if (isOnboardingCompleted) {
        // Go directly to main compass selection
        Get.offAllNamed('/');
      } else {
        // Show onboarding first
        Get.offAllNamed('/onboarding');
      }
    } catch (e) {
      // In case of error, default to onboarding
      Get.offAllNamed('/onboarding');
    }
  }
}
