import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'views/startup_view.dart';
import 'services/notification_service.dart';
import 'services/api_provider.dart';
import 'services/storage_provider.dart';
import 'services/database_provider.dart';
import 'services/cache_manager.dart';
import 'controllers/notification_controller.dart';
import 'features/compass/views/compass_selection_view.dart';
import 'features/onboarding/views/onboarding_view.dart';
import 'features/onboarding/bindings/onboarding_binding.dart';
import 'features/compass/views/basic_compass_view.dart';
import 'features/compass/views/personal_compass_view.dart';
import 'features/compass/views/personal_info_view.dart';
import 'features/compass/views/personal_compass_detail_view.dart';
import 'features/compass/bindings/compass_binding.dart';
import 'features/chat/views/chat_view.dart';
import 'features/chat/bindings/chat_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Skip setting auth token - server doesn't require it for chat API

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize StorageProvider
  await StorageProvider.init();

  // Initialize CacheManager
  await CacheManager.init();

  // Set orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  _initDependencies();

  runApp(const LabanPhongThuyApp());
}

// Initialize dependencies with lich-am style architecture
void _initDependencies() {
  // Core services - must be initialized first
  Get.put<ApiProvider>(ApiProvider(), permanent: true);
  Get.put<DatabaseProvider>(DatabaseProvider(), permanent: true);

  // Other permanent services
  Get.put<NotificationService>(NotificationService(), permanent: true);

  // Lazy controllers
  Get.lazyPut<NotificationController>(() => NotificationController(),
      fenix: true);
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
            GetPage(
              name: '/chat',
              page: () => const ChatView(),
              binding: ChatBinding(),
            ),
          ],
          initialRoute: '/',
        );
      },
    );
  }
}
