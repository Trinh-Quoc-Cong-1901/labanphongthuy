import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SplashController when splash view is created
    Get.put(SplashController());
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628), // Match app background
      body: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icon/logo_app.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
