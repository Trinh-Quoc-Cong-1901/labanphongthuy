import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
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
        appBar: _buildAppBar(controller),
        drawer: _buildDrawer(context),
        body: _buildBody(controller),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController controller) {
    return AppBar(
      backgroundColor: CompassUITheme.backgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
        tooltip: 'Back',
      ),
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
                  'Chuyên gia phong thủy',
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
        // History button to open drawer
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Lịch sử',
          ),
        ),
        // New chat button
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => controller.startNewConversation(),
          tooltip: 'Cuộc trò chuyện mới',
        ),
      ],
    );
  }

  // Build conversation history drawer
  Widget _buildDrawer(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: appBarHeight + MediaQuery.of(context).padding.top,
            color: CompassUITheme.backgroundColor,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Lịch sử trò chuyện',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 0,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GetBuilder<ChatController>(
              builder: (controller) => Obx(() {
                final conversations = controller.conversationHistory;

                return conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey[400],
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có lịch sử trò chuyện',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildConversationList(conversations, context);
              }),
            ),
          ),
          SafeArea(child: Container()),
        ],
      ),
    );
  }

  // Build conversation list
  Widget _buildConversationList(
      List<Conversation> conversations, BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(conversation, context);
      },
    );
  }

  // Build conversation tile
  Widget _buildConversationTile(
      Conversation conversation, BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (controller) => GestureDetector(
        onLongPress: () {
          _showDeleteMenu(context, conversation, controller);
        },
        child: ListTile(
          title: Text(
            conversation.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            _formatDate(conversation.updatedAt),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          onTap: () {
            controller.loadConversation(conversation.id);
            Get.back();
          },
        ),
      ),
    );
  }

  // Show delete menu
  void _showDeleteMenu(BuildContext context, Conversation conversation,
      ChatController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Xóa cuộc trò chuyện'),
                onTap: () {
                  Navigator.pop(context);
                  controller.deleteConversation(conversation.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Hủy'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Format date
  String _formatDate(DateTime date) {
    final dateTime = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Hôm nay, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildBody(ChatController controller) {
    return Column(
      children: [
        Expanded(
          child: Obx(() => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) =>
                    _buildMessageBubble(controller.messages[index]),
              )),
        ),
        _buildSuggestedQuestions(controller),
        _buildMessageInput(controller),
      ],
    );
  }

  // Build suggested questions
  Widget _buildSuggestedQuestions(ChatController controller) {
    return Obx(() {
      if (controller.suggestedQuestions.isEmpty ||
          controller.messages.length > 1) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        color: Colors.grey[50],
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.suggestedQuestions.length,
          itemBuilder: (context, index) {
            final question = controller.suggestedQuestions[index];
            return Container(
              margin: const EdgeInsets.only(right: 12),
              width: 250,
              child: Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: const Color(0xFFFDC24C).withOpacity(0.3)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      controller.useSuggestedQuestion(question.question),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
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
                color: message.isFromUser ? Color(0xFFFDC24C) : Colors.white,
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
                  _buildMessageContent(message),
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

  Widget _buildMessageContent(ChatMessage message) {
    final assistantTextStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFF333333),
      height: 1.4,
    );

    if (message.isFromUser) {
      return Text(
        message.content,
        style: ChatUITheme.userMessageTextStyle,
      );
    }

    if (message.isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDC24C)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Phong Vân đang suy nghĩ...',
            style: assistantTextStyle,
          ),
        ],
      );
    }

    return MarkdownBody(
      data: message.content.trim().isEmpty ? ' ' : message.content,
      styleSheet: MarkdownStyleSheet(
        p: assistantTextStyle,
        listBullet: assistantTextStyle,
        listIndent: 18,
        listBulletPadding: const EdgeInsets.only(right: 6),
        blockSpacing: 4,
      ),
      softLineBreak: true,
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
                controller: controller.messageController,
                focusNode: controller.messageFocusNode,
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
                autofocus: !controller.hasInitialMessage.value,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.sendMessage();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => GestureDetector(
                onTap: controller.messageText.value.trim().isEmpty ||
                        controller.isLoading.value
                    ? null
                    : controller.sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: controller.messageText.value.trim().isEmpty
                        ? Colors.grey[400]
                        : Color(0xFFFDC24C),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: controller.isLoading.value
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2C3E50)),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: controller.messageText.value.trim().isEmpty
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
