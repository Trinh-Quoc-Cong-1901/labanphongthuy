import 'package:get/get.dart';

import '../controllers/compass_controller.dart';
import '../services/sensor_service.dart';
import '../services/feng_shui_calculator.dart';

class CompassBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services first (as singletons)
    Get.lazyPut<SensorService>(() => SensorService.instance, fenix: true);
    Get.lazyPut<FengShuiCalculator>(() => FengShuiCalculator.instance, fenix: true);
    
    // Initialize compass controller
    Get.lazyPut<CompassController>(() => CompassController(), fenix: true);
  }
}