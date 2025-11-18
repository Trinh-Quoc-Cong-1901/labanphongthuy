import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../services/chat_service.dart';
import '../../../services/api_provider.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // ApiProvider is already registered in main.dart, no need to register again

    // Ensure ChatService is initialized (synchronously)
    Get.put<ChatService>(ChatService(), permanent: true);

    // Initialize controller
    Get.lazyPut<ChatController>(
      () => ChatController(),
    );
  }
}