import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_ai_service.dart';

class ChatController extends GetxController {
  // Observable list of messages
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  // Text editing controller for input field
  final TextEditingController textController = TextEditingController();

  // Loading state
  final RxBool isLoading = false.obs;

  // Scroll controller for auto-scroll
  final ScrollController scrollController = ScrollController();

  // Chat AI service
  final ChatAIService _chatService = ChatAIService();

  @override
  void onInit() {
    super.onInit();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Add welcome message from Phong Vân
  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Xin chào! Tôi là Phong Vân, trợ lý AI chuyên về phong thủy. Tôi có thể giúp bạn tư vấn về phong thủy, giải đáp các thắc mắc về hướng nhà, màu sắc may mắn, và nhiều vấn đề phong thủy khác. Bạn có cần hỗ trợ gì không?',
      isFromUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    messages.add(welcomeMessage);
  }

  /// Send user message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Create user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    // Add user message to list
    messages.add(userMessage);

    // Clear input
    textController.clear();

    // Auto scroll to bottom
    _scrollToBottom();

    // Show loading
    isLoading.value = true;

    try {
      // Get AI response
      final aiResponse = await _chatService.sendMessage(content.trim());

      // Create AI message
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        isFromUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      // Add AI message to list
      messages.add(aiMessage);

    } catch (e) {
      // Create error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Xin lỗi, tôi đang gặp sự cố kỹ thuật. Vui lòng thử lại sau.',
        isFromUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );

      messages.add(errorMessage);
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  /// Auto scroll to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Clear all messages
  void clearChat() {
    messages.clear();
    _addWelcomeMessage();
  }
}