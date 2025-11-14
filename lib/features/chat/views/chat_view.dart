import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import '../constants/chat_ui_theme.dart';
import '../../compass/constants/compass_ui_theme.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      init: ChatController(),
      builder: (controller) => Scaffold(
        backgroundColor: CompassUITheme.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(controller),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CompassUITheme.backgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Color(0xFFFDC24C),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phong Vân',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Trợ lý phong thủy thông minh',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        GetBuilder<ChatController>(
          builder: (controller) => IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _showClearDialog(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ChatController controller) {
    return Column(
      children: [
        Expanded(
          child: Obx(() => ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) => _buildMessageBubble(controller.messages[index]),
          )),
        ),
        _buildLoadingIndicator(controller),
        _buildMessageInput(controller),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            _buildAvatarAI(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isFromUser
                    ? Color(0xFFFDC24C)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isFromUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isFromUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: message.isFromUser
                        ? ChatUITheme.userMessageTextStyle
                        : TextStyle(
                            fontSize: 16,
                            color: Color(0xFF333333),
                            height: 1.4,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: message.isFromUser
                          ? Color(0xFF2C3E50).withValues(alpha: 0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromUser) ...[
            const SizedBox(width: 8),
            _buildAvatarUser(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarAI() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Color(0xFFFDC24C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Color(0xFF2C3E50),
        size: 18,
      ),
    );
  }

  Widget _buildAvatarUser() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildLoadingIndicator(ChatController controller) {
    return Obx(() => controller.isLoading.value
        ? Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatarAI(),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDC24C)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phong Vân đang suy nghĩ...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller.textController,
                decoration: InputDecoration(
                  hintText: 'Hỏi Phong Vân về phong thủy...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (value) => controller.sendMessage(value),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => GestureDetector(
            onTap: controller.isLoading.value
                ? null
                : () => controller.sendMessage(controller.textController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: controller.isLoading.value
                    ? Colors.grey[400]
                    : Color(0xFFFDC24C),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.send,
                color: controller.isLoading.value
                    ? Colors.white
                    : Color(0xFF2C3E50),
                size: 20,
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showClearDialog(ChatController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xóa cuộc trò chuyện'),
        content: const Text('Bạn có muốn xóa toàn bộ cuộc trò chuyện không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.clearChat();
              Get.back();
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}