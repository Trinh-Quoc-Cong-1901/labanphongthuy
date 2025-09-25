import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/onboarding_service.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    try {
      // Let native splash show for a moment
      await Future.delayed(const Duration(milliseconds: 800));

      // Check onboarding status
      final isOnboardingCompleted = await OnboardingService.isOnboardingCompleted();

      if (mounted) {
        // For debugging - force go to compass
        Get.offAllNamed('/compass');

        // Original logic:
        // if (isOnboardingCompleted) {
        //   Get.offAllNamed('/compass');
        // } else {
        //   Get.offAllNamed('/onboarding');
        // }
      }
    } catch (e) {
      // In case of error, force go to compass for debugging
      if (mounted) {
        Get.offAllNamed('/compass');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container with app background while navigating
    // Native splash is still showing during this time
    return const Scaffold(
      backgroundColor: Color(0xFF0A1628),
      body: SizedBox(),
    );
  }
}