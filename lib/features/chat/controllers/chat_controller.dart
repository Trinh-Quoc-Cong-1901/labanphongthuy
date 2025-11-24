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
  final RxList<SuggestedQuestion> suggestedQuestions =
      <SuggestedQuestion>[].obs;
  final Rx<String?> currentConversationId = Rx<String?>(null);
  final Rx<String> selectedModel =
      'gemini'.obs; // Use gemini model as confirmed by server

  // Conversation history
  final RxList<Conversation> conversationHistory = <Conversation>[].obs;

  final RxList<Map<String, dynamic>> availableModels =
      <Map<String, dynamic>>[].obs;

  // For tracking loading state when sending a message
  final Rx<ChatMessage?> loadingMessage = Rx<ChatMessage?>(null);

  // Track if we have initialMessage to control autofocus
  final Rx<bool> hasInitialMessage = false.obs;

  // Listen to message controller text changes
  final Rx<String> messageText = ''.obs;

  Future<String> _resolveUserId() => _chatService.getOrCreateUserId();

  @override
  void onInit() {
    super.onInit();
    _initializeWithChatService();

    // Listen to text changes
    messageController.addListener(() {
      messageText.value = messageController.text;
    });
  }

  @override
  void onReady() {
    super.onReady();

    // Immediate fallback - show default questions right away
    if (suggestedQuestions.isEmpty) {
      LoggerUtils.debug('ChatController: onReady - Setting immediate fallback questions');
      final immediateFallbackQuestions = [
        SuggestedQuestion(
          id: 'fallback1',
          question: 'Hướng nào tốt nhất cho cửa chính của ngôi nhà?',
          category: 'laBan',
        ),
        SuggestedQuestion(
          id: 'fallback2',
          question: 'Cách bố trí phòng khách theo phong thủy?',
          category: 'nhaO',
        ),
        SuggestedQuestion(
          id: 'fallback3',
          question: 'Hướng ngồi làm việc nào mang lại may mắn?',
          category: 'vanPhong',
        ),
        SuggestedQuestion(
          id: 'fallback4',
          question: 'Màu sắc may mắn cho người sinh năm 1990?',
          category: 'mauSac',
        ),
      ];
      suggestedQuestions.assignAll(immediateFallbackQuestions);
    }

    // Force reload suggested questions after the view is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      LoggerUtils.debug('ChatController: onReady - Force reloading suggested questions');
      _loadSuggestedQuestions();

      // If still empty after a delay, try to reinitialize the ChatService
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (suggestedQuestions.length <= 4) {  // Only fallback questions
          LoggerUtils.debug('ChatController: Still only fallback questions, forcing ChatService reinit...');
          forceReinitializeSuggestedQuestions();
        }
      });
    });
  }

  Future<void> _initializeWithChatService() async {
    try {
      // Try to get the ChatService to check if it's available
      Get.find<ChatService>();

      // If we get here, the service is available
      _loadAvailableModels();
      _loadSuggestedQuestions();
      await _loadConversationHistory();
      _showInitialGreetingIfNeeded();
    } catch (e) {
      LoggerUtils.debug('ChatService not ready yet, retrying...');
      // Retry after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await _initializeWithChatService();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }

  // Load conversation history
  Future<void> _loadConversationHistory() async {
    try {
      final userId = await _resolveUserId();
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
        // Use gemini model specifically
        selectedModel.value = 'gemini';
      }
    } catch (e) {
      LoggerUtils.error('Failed to load available models: $e');
    }
  }

  // Load suggested questions
  void _loadSuggestedQuestions() {
    LoggerUtils.debug('ChatController: Loading suggested questions...');
    try {
      final allQuestions = _chatService.getSuggestedQuestions();
      LoggerUtils.debug('ChatController: Got ${allQuestions.length} questions from service');

      if (allQuestions.isEmpty) {
        LoggerUtils.debug('ChatController: No suggested questions available, using fallback questions');
        // Use fallback questions instead of clearing
        final fallbackQuestions = [
          SuggestedQuestion(
            id: 'fallback1',
            question: 'Hướng nào tốt nhất cho cửa chính của ngôi nhà?',
            category: 'laBan',
          ),
          SuggestedQuestion(
            id: 'fallback2',
            question: 'Cách bố trí phòng khách theo phong thủy?',
            category: 'nhaO',
          ),
          SuggestedQuestion(
            id: 'fallback3',
            question: 'Hướng ngồi làm việc nào mang lại may mắn?',
            category: 'vanPhong',
          ),
          SuggestedQuestion(
            id: 'fallback4',
            question: 'Màu sắc may mắn cho người sinh năm 1990?',
            category: 'mauSac',
          ),
        ];
        suggestedQuestions.assignAll(fallbackQuestions);
        return;
      }

      // Only hide questions when we actually have user messages with real content
      final userMessages = messages.where((message) =>
          message.role == MessageRole.user &&
          message.content.isNotEmpty &&
          !message.isLoading
      ).toList();

      LoggerUtils.debug('ChatController: User messages count: ${userMessages.length}, Total messages: ${messages.length}');

      if (userMessages.isEmpty) {
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

        final finalQuestions = selectedQuestions.take(6).toList();
        LoggerUtils.debug('ChatController: No user messages, showing ${finalQuestions.length} default questions');
        suggestedQuestions.assignAll(finalQuestions);
        return;
      }

      // Based on the last few messages, suggest related questions
      final lastMessageContent =
          messages.lastOrNull?.content.toLowerCase() ?? '';

      // Filter questions by content relation
      final filteredQuestions = allQuestions.where((question) {
        // Check for keyword matches
        if (lastMessageContent.contains('la bàn') ||
            lastMessageContent.contains('hướng')) {
          return question.category == QuestionCategory.laBan.name;
        }
        if (lastMessageContent.contains('nhà') ||
            lastMessageContent.contains('phòng')) {
          return question.category == QuestionCategory.nhaO.name;
        }
        if (lastMessageContent.contains('văn phòng') ||
            lastMessageContent.contains('làm việc')) {
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

      // If we have user messages, we'll hide the questions via the UI logic
      // This method is mainly called when starting new conversations
      LoggerUtils.debug('ChatController: User messages exist, questions will be hidden by UI');
    } catch (e) {
      LoggerUtils.error('ChatController: Error loading suggested questions', e);
      // Don't clear on error, keep existing questions
    }
  }

  void _showInitialGreetingIfNeeded() {
    if (messages.isEmpty && !hasInitialMessage.value) {
      final welcomeMessage = ChatMessage(
        id: _uuid.v4(),
        content:
            'Chào bạn! Tôi là Phong Vân – chuyên gia phong thủy. Bạn muốn hỏi gì từ AI hôm nay?',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );
      messages.add(welcomeMessage);
      hasInitialMessage.value = true;
    }
  }

  // Force reinitialize suggested questions when they're not loading properly
  Future<void> forceReinitializeSuggestedQuestions() async {
    try {
      LoggerUtils.debug('ChatController: Force reinitializing suggested questions...');

      // Use the new force reset method from ChatService
      await _chatService.forceResetSuggestedQuestions();

      // Retry loading
      _loadSuggestedQuestions();

      // If still empty, add some default questions directly
      if (suggestedQuestions.isEmpty) {
        LoggerUtils.debug('ChatController: Creating fallback suggested questions...');
        final fallbackQuestions = [
          SuggestedQuestion(
            id: '1',
            question: 'Hướng nào tốt nhất cho cửa chính của ngôi nhà?',
            category: 'laBan',
          ),
          SuggestedQuestion(
            id: '2',
            question: 'Cách bố trí phòng khách theo phong thủy?',
            category: 'nhaO',
          ),
          SuggestedQuestion(
            id: '3',
            question: 'Hướng ngồi làm việc nào mang lại may mắn?',
            category: 'vanPhong',
          ),
          SuggestedQuestion(
            id: '4',
            question: 'Màu sắc may mắn cho người sinh năm 1990?',
            category: 'mauSac',
          ),
        ];
        suggestedQuestions.assignAll(fallbackQuestions);
        LoggerUtils.debug('ChatController: Assigned ${fallbackQuestions.length} fallback questions');
      }
    } catch (e) {
      LoggerUtils.error('ChatController: Error in force reinitialize suggested questions', e);
    }
  }

  // Send a message
  Future<void> sendMessage({String? text}) async {
    final message = text ?? messageController.text.trim();
    final String messageFromInput = message;
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

      // Lunar service removed for now
      final dateTimeContext = "\n\n--- Thông tin thời gian hiện tại ---\n"
          "Ngày giờ: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}\n"
          "Thứ: ${_getDayOfWeek(now.weekday)}\n"
          "--- Hết thông tin thời gian ---";

      messageToSendToAI = "$messageToSendToAI$dateTimeContext";

      LoggerUtils.debug("Message to send to AI:\n$messageToSendToAI");
      // --- END MODIFICATION ---
      // Create a placeholder loading message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: messageFromInput,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      // Add user message to UI
      messages.add(userMessage);
      messageFocusNode.unfocus();

      final loadingResponseMessage = ChatMessage(
        id: _uuid.v4(),
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
        isLoading: true,
      );

      messages.add(loadingResponseMessage);
      loadingMessage.value = loadingResponseMessage;

      messageFocusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 450), _scrollToBottom);
      isTyping.value = true;

      try {
        final userId = await _resolveUserId();
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
              (msg.content.contains('--- Thông tin người dùng ---') ||
                  msg.content.contains('--- Thông tin chi tiết quẻ ---') ||
                  msg.content.contains(
                    '--- Thông tin thời gian hiện tại ---',
                  ))) {
            // Extract original message from user context or divination info
            String originalMessage = msg.content;

            // Remove datetime context if present
            if (originalMessage.contains(
              '--- Thông tin thời gian hiện tại ---',
            )) {
              originalMessage = originalMessage
                  .split('\n\n--- Thông tin thời gian hiện tại ---')
                  .first;
            }

            // Remove user context if present
            if (originalMessage.contains('--- Thông tin người dùng ---')) {
              originalMessage = originalMessage
                  .split('\n\n--- Thông tin người dùng ---')
                  .first;
            }

            // Remove divination info if present
            if (originalMessage.contains(
              '--- Thông tin chi tiết quẻ ---',
            )) {
              originalMessage = originalMessage
                  .split('\n\n--- Thông tin chi tiết quẻ ---')
                  .first;
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
        await _loadConversationHistory();

        // Update suggested questions based on the new message
        _loadSuggestedQuestions();
      } catch (e) {
        LoggerUtils.error('Error sending message', e);

        // Remove loading message and show error
        final updatedMessages =
            messages.where((msg) => !msg.isLoading).toList();

        // Add error message from API
        updatedMessages.add(
          ChatMessage(
            id: _uuid.v4(),
            content: 'Đã xảy ra lỗi khi gửi tin nhắn: ${e.toString()}',
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
          ),
        );

        messages.assignAll(updatedMessages);
      } finally {
        // Clear loading state
        loadingMessage.value = null;
        isLoading.value = false;
        isTyping.value = false;

        // Scroll to bottom after a short delay to ensure the list has updated
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    } catch (e) {
      LoggerUtils.error('Unexpected error in sendMessage', e);

      // Clear loading state in case of unexpected error
      loadingMessage.value = null;
      isLoading.value = false;
      isTyping.value = false;

      // Remove loading message and show error
      final updatedMessages = messages.where((msg) => !msg.isLoading).toList();

      // Add error message
      updatedMessages.add(
        ChatMessage(
          id: _uuid.v4(),
          content: 'Đã xảy ra lỗi không mong muốn: ${e.toString()}',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      );

      messages.assignAll(updatedMessages);
    }
  }

  // Use a suggested question
  void useSuggestedQuestion(String question) {
    sendMessage(text: question);
  }

  // Add a custom suggested question
  Future<void> addCustomSuggestedQuestion(
      String question, String category) async {
    await _chatService.addSuggestedQuestion(question, category);
    _loadSuggestedQuestions();
  }

  // Load a conversation
  Future<void> loadConversation(String conversationId) async {
    try {
      isLoading.value = true;
      final userId = await _resolveUserId();
      final conversation = _chatService.getConversation(userId, conversationId);
      if (conversation != null) {
        currentConversationId.value = conversationId;

        // Clean user messages to show original input only
        final cleanedMessages = conversation.messages.map((msg) {
          if (msg.role == MessageRole.user &&
              (msg.content.contains('--- Thông tin người dùng ---') ||
                  msg.content.contains('--- Thông tin chi tiết quẻ ---') ||
                  msg.content.contains(
                    '--- Thông tin thời gian hiện tại ---',
                  ))) {
            // Extract original message from user context or divination info
            String originalMessage = msg.content;

            // Remove datetime context if present
            if (originalMessage.contains(
              '--- Thông tin thời gian hiện tại ---',
            )) {
              originalMessage = originalMessage
                  .split('\n\n--- Thông tin thời gian hiện tại ---')
                  .first;
            }

            // Remove user context if present
            if (originalMessage.contains('--- Thông tin người dùng ---')) {
              originalMessage = originalMessage
                  .split('\n\n--- Thông tin người dùng ---')
                  .first;
            }

            // Remove divination info if present
            if (originalMessage.contains(
              '--- Thông tin chi tiết quẻ ---',
            )) {
              originalMessage = originalMessage
                  .split('\n\n--- Thông tin chi tiết quẻ ---')
                  .first;
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

        messages.assignAll(cleanedMessages);
        // Reset hasInitialMessage to allow autofocus for existing conversation
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
    _showInitialGreetingIfNeeded();
  }

  // Delete current conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final userId = await _resolveUserId();
      await _chatService.deleteConversation(userId, conversationId);

      // Remove conversation from RxList directly to update UI immediately
      final index =
          conversationHistory.indexWhere((conv) => conv.id == conversationId);
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
      final userId = await _resolveUserId();
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
