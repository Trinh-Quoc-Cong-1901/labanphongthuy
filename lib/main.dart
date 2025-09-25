import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'views/startup_view.dart';
import 'features/compass/views/compass_selection_view.dart';
import 'features/onboarding/views/onboarding_view.dart';
import 'features/onboarding/bindings/onboarding_binding.dart';
import 'features/compass/views/basic_compass_view.dart';
import 'features/compass/views/personal_compass_view.dart';
import 'features/compass/views/personal_info_view.dart';
import 'features/compass/views/personal_compass_detail_view.dart';
import 'features/compass/bindings/compass_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const LabanPhongThuyApp());
}

class LabanPhongThuyApp extends StatelessWidget {
  const LabanPhongThuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'La Bàn Phong Thủy',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'SVN-Gilroy',
            textTheme: TextTheme(
              bodyMedium: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
              titleLarge: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Routes
          getPages: [
            GetPage(
              name: '/',
              page: () => const StartupView(),
            ),
            GetPage(
              name: '/onboarding',
              page: () => const OnboardingView(),
              binding: OnboardingBinding(),
            ),
            GetPage(
              name: '/compass',
              page: () => CompassSelectionView(),
              binding: CompassBinding(),
            ),
            GetPage(
              name: '/compass/basic',
              page: () => BasicCompassView(),
              binding: CompassBinding(),
            ),
            GetPage(
              name: '/compass/personal',
              page: () => PersonalCompassView(),
              binding: CompassBinding(),
            ),
            GetPage(
              name: '/compass/personal/info',
              page: () => PersonalInfoView(),
              binding: CompassBinding(),
            ),
            GetPage(
              name: '/compass/personal/detail',
              page: () => PersonalCompassDetailView(),
              binding: CompassBinding(),
            ),
          ],
          initialRoute: '/',
        );
      },
    );
  }
}
