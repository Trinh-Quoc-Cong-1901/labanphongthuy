import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/suggested_question.dart';
import '../services/chat_service.dart';
import '../../../utils/logger_utils.dart';
// import '../../lunar_calendar/services/lunar_service.dart';

class ChatController extends GetxController {
  // Chat service
  final ChatService _chatService = Get.find<ChatService>();
  final Uuid _uuid = const Uuid();

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();

  // State
  final Rx<bool> isLoading = false.obs;
  final Rx<bool> isTyping = false.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<SuggestedQuestion> suggestedQuestions = <SuggestedQuestion>[].obs;
  final Rx<String?> currentConversationId = Rx<String?>(null);
  final Rx<String> selectedModel = 'lao_dai'.obs; // Match lich-am model

  // Conversation history
  final RxList<Conversation> conversationHistory = <Conversation>[].obs;

  final RxList<Map<String, dynamic>> availableModels = <Map<String, dynamic>>[].obs;

  // For tracking loading state when sending a message
  final Rx<ChatMessage?> loadingMessage = Rx<ChatMessage?>(null);

  // Track if we have initialMessage to control autofocus
  final Rx<bool> hasInitialMessage = false.obs;

  // Listen to message controller text changes
  final Rx<String> messageText = ''.obs;

  String get userId => 'anonymous'; // Match lich-am exactly

  @override
  void onInit() {
    super.onInit();
    _loadAvailableModels();
    _loadSuggestedQuestions();
    _loadConversationHistory();

    // Listen to text changes
    messageController.addListener(() {
      messageText.value = messageController.text;
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }

  // Load conversation history
  void _loadConversationHistory() {
    try {
      final conversations = _chatService.getAllConversations(userId);
      conversationHistory.value = conversations;
    } catch (e) {
      LoggerUtils.error('Error loading conversation history: $e');
    }
  }

  // Load available AI models
  Future<void> _loadAvailableModels() async {
    try {
      final models = await _chatService.getAvailableModels();
      availableModels.assignAll(models);
      if (models.isNotEmpty) {
        selectedModel.value = models.first['id'].toString();
      }
    } catch (e) {
      LoggerUtils.error('Failed to load available models: $e');
    }
  }

  // Load suggested questions
  void _loadSuggestedQuestions() {
    final allQuestions = _chatService.getSuggestedQuestions();

    // If there are no messages, show initial suggested questions
    if (messages.isEmpty) {
      // Show a varied selection from each category
      final categorized = _chatService.getSuggestedQuestionsByCategory();
      final selectedQuestions = <SuggestedQuestion>[];

      for (final category in categorized.keys) {
        if (categorized[category]!.isNotEmpty) {
          // Take up to 2 questions from each category
          selectedQuestions.addAll(categorized[category]!
              .take(category == QuestionCategory.tongQuat.name ? 2 : 1));
        }
      }

      suggestedQuestions.assignAll(selectedQuestions.take(6).toList());
    } else {
      // Based on the last few messages, suggest related questions
      final lastMessageContent = messages.lastOrNull?.content.toLowerCase() ?? '';

      // Filter questions by content relation
      final filteredQuestions = allQuestions.where((question) {
        // Check for keyword matches
        if (lastMessageContent.contains('la bàn') || lastMessageContent.contains('hướng')) {
          return question.category == QuestionCategory.laBan.name;
        }
        if (lastMessageContent.contains('nhà') || lastMessageContent.contains('phòng')) {
          return question.category == QuestionCategory.nhaO.name;
        }
        if (lastMessageContent.contains('văn phòng') || lastMessageContent.contains('làm việc')) {
          return question.category == QuestionCategory.vanPhong.name;
        }
        if (lastMessageContent.contains('màu')) {
          return question.category == QuestionCategory.mauSac.name;
        }
        if (lastMessageContent.contains('ngày')) {
          return question.category == QuestionCategory.ngayTot.name;
        }

        return false;
      }).toList();

      // If no specific matches, show general questions
      if (filteredQuestions.isEmpty) {
        final generalQuestions = allQuestions
            .where((q) => q.category == QuestionCategory.tongQuat.name)
            .take(4)
            .toList();
        suggestedQuestions.assignAll(generalQuestions);
      } else {
        // Take up to 4 filtered questions
        suggestedQuestions.assignAll(filteredQuestions.take(4).toList());
      }
    }
  }

  // Send a message - EXACT COPY FROM LICH-AM
  Future<void> sendMessage({String? text}) async {
    final message = text ?? messageController.text.trim();
    final String messageFromInput = text ?? messageController.text.trim();
    if (message.isEmpty) return;

    // Clear the text controller if text wasn't passed in
    if (text == null) {
      messageController.clear();
    }

    try {
      isLoading.value = true;
      // --- START MODIFICATION: Chuẩn bị message để gửi cho AI ---
      String messageToSendToAI = messageFromInput;

      // Thêm ngày giờ hiện tại
      final now = DateTime.now();

      // Simplified datetime context without lunar calendar for now
      final dateTimeContext = "\n\n--- Thông tin thời gian hiện tại ---\n"
          "Ngày giờ: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}\n"
          "Thứ: ${_getDayOfWeek(now.weekday)}\n"
          "--- Hết thông tin thời gian ---";

      messageToSendToAI = "$messageToSendToAI$dateTimeContext";

      LoggerUtils.debug("Message to send to AI (with context):\n$messageToSendToAI");
      // --- END MODIFICATION ---
      // Create a placeholder loading message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: messageFromInput,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      final loadingResponseMessage = ChatMessage(
        id: _uuid.v4(),
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
        isLoading: true,
      );

      // Add messages to UI
      messages.add(userMessage);
      messages.add(loadingResponseMessage);

      // Set loading message reference
      loadingMessage.value = loadingResponseMessage;

      // Automatically unfocus the text field
      messageFocusNode.unfocus();

      // Scroll to bottom with a short delay
      Future.delayed(const Duration(milliseconds: 450), _scrollToBottom);

      // Set typing indicator
      isTyping.value = true;
      // --- START MODIFICATION: Gửi `messageToSendToAI` cho service ---
      final conversation = await _chatService.sendMessage(
        userId: userId,
        message: messageToSendToAI, // <<< GỬI MESSAGE ĐÃ CHUẨN BỊ CHO AI >>>
        model: selectedModel.value,
        conversationId: currentConversationId.value,
      );
      // --- END MODIFICATION ---

      // Update conversation ID
      currentConversationId.value = conversation.id;

      // Update messages from conversation, but ensure user message shows original input
      final updatedMessages = conversation.messages.map((msg) {
        if (msg.role == MessageRole.user &&
            (msg.content.contains('--- Thông tin thời gian hiện tại ---'))) {
          // Extract original message from datetime context
          String originalMessage = msg.content;

          // Remove datetime context if present
          if (originalMessage.contains('--- Thông tin thời gian hiện tại ---')) {
            originalMessage = originalMessage.split('\n\n--- Thông tin thời gian hiện tại ---').first;
          }

          return ChatMessage(
            id: msg.id,
            content: originalMessage,
            role: msg.role,
            timestamp: msg.timestamp,
            isLoading: msg.isLoading,
          );
        }
        return msg;
      }).toList();

      messages.assignAll(updatedMessages);

      // Update conversation history immediately after sending a message
      _loadConversationHistory();

      // Update suggested questions based on the new message
      _loadSuggestedQuestions();
    } catch (e) {
      LoggerUtils.error('Error sending message', e);
    } finally {
      // Clear loading state
      loadingMessage.value = null;
      isLoading.value = false;
      isTyping.value = false;

      // Scroll to bottom after a short delay to ensure the list has updated
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    }
  }

  // Use a suggested question
  void useSuggestedQuestion(String question) {
    sendMessage(text: question);
  }

  // Add a custom suggested question
  Future<void> addCustomSuggestedQuestion(String question, String category) async {
    await _chatService.addSuggestedQuestion(question, category);
    _loadSuggestedQuestions();
  }

  // Load a conversation
  Future<void> loadConversation(String conversationId) async {
    try {
      isLoading.value = true;

      final conversation = _chatService.getConversation(userId, conversationId);
      if (conversation != null) {
        currentConversationId.value = conversationId;

        // No context processing needed - we send pure messages
        messages.assignAll(conversation.messages);
        hasInitialMessage.value = false;
        _loadSuggestedQuestions();

        // Scroll to bottom after loading conversation
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    } catch (e) {
      LoggerUtils.error('Error loading conversation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Start a new conversation
  void startNewConversation() {
    currentConversationId.value = null;
    messages.clear();
    hasInitialMessage.value = false;
    _loadSuggestedQuestions();
  }

  // Delete current conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _chatService.deleteConversation(userId, conversationId);

      // Remove conversation from RxList directly to update UI immediately
      final index = conversationHistory.indexWhere((conv) => conv.id == conversationId);
      if (index >= 0) {
        conversationHistory.removeAt(index);
      }

      // If we're deleting the current conversation, start a new one
      if (conversationId == currentConversationId.value) {
        startNewConversation();
      }
    } catch (e) {
      LoggerUtils.error('Error deleting conversation: $e');
    }
  }

  // Clear all conversations
  Future<void> clearAllConversations() async {
    try {
      await _chatService.clearAllConversations(userId);
      startNewConversation();

      // Clear the conversation history list directly
      conversationHistory.clear();
    } catch (e) {
      LoggerUtils.error('Error clearing all conversations: $e');
    }
  }

  // Get conversation history
  List<Conversation> getConversationHistory() {
    return conversationHistory;
  }

  // Helper to scroll to bottom of chat
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    }
  }

  /// Clear all messages (legacy method for compatibility)
  void clearChat() {
    startNewConversation();
  }

  // Helper function to get day of week in Vietnamese
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return "Thứ Hai";
      case 2:
        return "Thứ Ba";
      case 3:
        return "Thứ Tư";
      case 4:
        return "Thứ Năm";
      case 5:
        return "Thứ Sáu";
      case 6:
        return "Thứ Bảy";
      case 7:
        return "Chủ Nhật";
      default:
        return "";
    }
  }

}
