import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../../compass/constants/compass_ui_theme.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return GetBuilder<ChatController>(
              init: ChatController(),
              builder: (controller) {
                final isLandscape = orientation == Orientation.landscape;

                return Scaffold(
                  backgroundColor: CompassUITheme.backgroundColor,
                  appBar: _buildAppBar(controller, isLandscape),
                  drawer: isLandscape ? null : _buildDrawer(context), // Hide drawer in landscape
                  body: isLandscape
                      ? _buildLandscapeBody(controller)
                      : _buildBody(controller),
                  endDrawer: isLandscape ? _buildDrawer(context) : null, // Show as end drawer in landscape
                );
              },
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController controller, [bool isLandscape = false]) {
    return AppBar(
      backgroundColor: CompassUITheme.backgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      toolbarHeight: isLandscape ? 56.h : 56.h, // Adjustable height based on orientation
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
        tooltip: 'Back',
      ),
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(
              Icons.smart_toy,
              color: const Color(0xFFFDC24C),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phong Vân',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Chuyên gia phong thủy',
                  style: TextStyle(
                    fontSize: 12.sp,
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
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Lịch sử trò chuyện',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey[300],
            thickness: 1.h,
            height: 0,
          ),
          SizedBox(height: 8.h),
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
                              size: 48.sp,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Không có lịch sử trò chuyện',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildConversationList(conversations, context);
              }),
            ),
          ),
          SafeArea(
            child: GetBuilder<ChatController>(
              builder: (controller) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      'Tổng số: ${controller.conversationHistory.length} cuộc trò chuyện',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.sp,
                      ),
                    )),
                    IconButton(
                      icon: Icon(Icons.close, size: 20.sp),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
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
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            _formatDate(conversation.updatedAt),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.sp,
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
    return SafeArea(
      top: false, // AppBar handles top safe area
      child: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    16.h,
                    16.w,
                    0, // No bottom padding since message input handles it
                  ),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(controller.messages[index]),
                )),
          ),
          _buildSuggestedQuestions(controller),
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  // Optimized landscape layout
  Widget _buildLandscapeBody(ChatController controller) {
    return SafeArea(
      child: Row(
        children: [
          // Chat messages area - takes up most of the space
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() => ListView.builder(
                        controller: controller.scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageBubble(controller.messages[index]),
                      )),
                ),
                _buildMessageInput(controller),
              ],
            ),
          ),
          // Suggested questions sidebar in landscape
          Container(
            width: 1.sw > 1024 ? 350.w : 300.w, // Adaptive width based on screen size
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(left: BorderSide(color: Colors.grey[300]!, width: 1.w)),
            ),
            child: SafeArea(
              left: false, // Don't apply left safe area since it's not at the edge
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1.h)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Câu hỏi gợi ý',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.close, size: 20.sp),
                            onPressed: () => Scaffold.of(context).closeEndDrawer(),
                            color: Colors.grey[600],
                            tooltip: 'Đóng',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildLandscapeSuggestedQuestions(controller),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build suggested questions
  Widget _buildSuggestedQuestions(ChatController controller) {
    return Obx(() {
      // Hide if no questions available
      if (controller.suggestedQuestions.isEmpty) {
        return const SizedBox.shrink();
      }

      // Only hide when we actually have user messages with real content
      final userMessages = controller.messages.where((message) =>
          message.role == MessageRole.user &&
          message.content.isNotEmpty &&
          !message.isLoading
      ).toList();

      if (userMessages.isNotEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 120.h,
        padding: EdgeInsets.all(16.w),
        color: Colors.grey[50],
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.suggestedQuestions.length,
          itemBuilder: (context, index) {
            final question = controller.suggestedQuestions[index];
            return Container(
              margin: EdgeInsets.only(right: 12.w),
              width: 250.w,
              child: Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                      color: const Color(0xFFFDC24C).withValues(alpha: 0.3)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () =>
                      controller.useSuggestedQuestion(question.question),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: const Color(0xFF333333),
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

  // Landscape suggested questions layout
  Widget _buildLandscapeSuggestedQuestions(ChatController controller) {
    return Obx(() {
      // Hide if no questions available
      if (controller.suggestedQuestions.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'Không có câu hỏi gợi ý',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      // Only hide when we actually have user messages with real content
      final userMessages = controller.messages.where((message) =>
          message.role == MessageRole.user &&
          message.content.isNotEmpty &&
          !message.isLoading
      ).toList();

      if (userMessages.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'Cuộc trò chuyện đã bắt đầu',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.suggestedQuestions.length,
        itemBuilder: (context, index) {
          final question = controller.suggestedQuestions[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                    color: const Color(0xFFFDC24C).withValues(alpha: 0.3)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () => controller.useSuggestedQuestion(question.question),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF333333),
                      height: 1.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      constraints: BoxConstraints(
        maxWidth: 1.sw * 0.85, // Max width is 85% of screen width
      ),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            _buildAvatarAI(),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 1.sw * (1.sw > 768 ? 0.6 : 0.75), // Responsive max width
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: message.isFromUser ? const Color(0xFFFDC24C) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(message.isFromUser ? 16.r : 4.r),
                  bottomRight: Radius.circular(message.isFromUser ? 4.r : 16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(message),
                  SizedBox(height: 4.h),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: message.isFromUser
                          ? const Color(0xFF2C3E50).withValues(alpha: 0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromUser) ...[
            SizedBox(width: 8.w),
            _buildAvatarUser(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    final assistantTextStyle = TextStyle(
      fontSize: 16.sp,
      color: const Color(0xFF333333),
      height: 1.4,
    );

    if (message.isFromUser) {
      return Text(
        message.content,
        style: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xFF2C3E50),
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (message.isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 18.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDC24C)),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              'Phong Vân đang suy nghĩ...',
              style: assistantTextStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return MarkdownBody(
      data: message.content.trim().isEmpty ? ' ' : message.content,
      styleSheet: MarkdownStyleSheet(
        p: assistantTextStyle,
        listBullet: assistantTextStyle,
        listIndent: 18.w,
        listBulletPadding: EdgeInsets.only(right: 6.w),
        blockSpacing: 4.h,
      ),
      softLineBreak: true,
    );
  }

  Widget _buildAvatarAI() {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFDC24C),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        Icons.smart_toy,
        color: const Color(0xFF2C3E50),
        size: 18.sp,
      ),
    );
  }

  Widget _buildAvatarUser() {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 18.sp,
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: controller.messageController,
                  focusNode: controller.messageFocusNode,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Hỏi Phong Vân về phong thủy...',
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
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
            SizedBox(width: 8.w),
            Obx(() => GestureDetector(
                  onTap: controller.messageText.value.trim().isEmpty ||
                          controller.isLoading.value
                      ? null
                      : controller.sendMessage,
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: controller.messageText.value.trim().isEmpty
                          ? Colors.grey[400]
                          : const Color(0xFFFDC24C),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: controller.isLoading.value
                        ? Center(
                            child: SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
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
                                : const Color(0xFF2C3E50),
                            size: 20.sp,
                          ),
                  ),
                )),
          ],
        ),
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
