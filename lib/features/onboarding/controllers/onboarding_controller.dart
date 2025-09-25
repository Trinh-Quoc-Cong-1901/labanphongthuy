import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/onboarding_service.dart';

class OnboardingController extends GetxController {
  late PageController pageController;

  // Current page index (observable)
  final RxInt currentIndex = 0.obs;

  // Total number of onboarding pages
  static const int totalPages = 3;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Navigate to next page
  void nextPage() {
    if (currentIndex.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - complete onboarding
      completeOnboarding();
    }
  }

  // Navigate to previous page
  void previousPage() {
    if (currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Skip onboarding
  void skipOnboarding() {
    completeOnboarding();
  }

  // Complete onboarding and navigate to main app
  void completeOnboarding() async {
    // Save onboarding completed status to SharedPreferences
    await OnboardingService.setOnboardingCompleted();
    Get.offAllNamed('/compass');
  }

  // Update current page index
  void updatePageIndex(int index) {
    currentIndex.value = index;
  }

  // Check if it's the last page
  bool get isLastPage => currentIndex.value == totalPages - 1;

  // Check if it's the first page
  bool get isFirstPage => currentIndex.value == 0;
}