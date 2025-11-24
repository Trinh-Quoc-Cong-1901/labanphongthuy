import 'package:get/get.dart';

import '../controllers/compass_controller.dart';
import '../services/feng_shui_calculator.dart';

class CompassBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services as lazy singletons - only when needed
    // This prevents heavy sensor initialization on app startup
    Get.lazyPut<FengShuiCalculator>(() => FengShuiCalculator.instance,
        fenix: true);

    // Initialize compass controller without auto-starting sensors
    Get.lazyPut<CompassController>(() => CompassController(), fenix: true);
  }
}
