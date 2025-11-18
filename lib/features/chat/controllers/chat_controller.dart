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
  final Rx<String> selectedModel = 'gemini'.obs; // Use gemini model as confirmed by server

  // Conversation history
  final RxList<Conversation> conversationHistory = <Conversation>[].obs;

  final RxList<Map<String, dynamic>> availableModels = <Map<String, dynamic>>[].obs;

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

  Future<void> _initializeWithChatService() async {
    try {
      // Try to get the ChatService to check if it's available
      Get.find<ChatService>();

      // If we get here, the service is available
      _loadAvailableModels();
      _loadSuggestedQuestions();
      await _loadConversationHistory();
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
      final dateTimeContext =
          "\n\n--- Thông tin thời gian hiện tại ---\n"
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

      // Check if the question is allowed
      if (!_isAllowedTopic(messageFromInput)) {
        messages.add(
          ChatMessage(
            id: _uuid.v4(),
            content:
                'Phong Vân chỉ trả lời những câu hỏi liên quan đến phong thủy, la bàn phong thủy hoặc hướng. Vui lòng hỏi lại theo chủ đề phù hợp.',
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
          ),
        );

        // Reset loading flags
        isLoading.value = false;
        isTyping.value = false;
        loadingMessage.value = null;

        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
        return;
      }

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
        final updatedMessages =
            conversation.messages.map((msg) {
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
                  originalMessage =
                      originalMessage
                          .split('\n\n--- Thông tin thời gian hiện tại ---')
                          .first;
                }

                // Remove user context if present
                if (originalMessage.contains('--- Thông tin người dùng ---')) {
                  originalMessage =
                      originalMessage
                          .split('\n\n--- Thông tin người dùng ---')
                          .first;
                }

                // Remove divination info if present
                if (originalMessage.contains(
                  '--- Thông tin chi tiết quẻ ---',
                )) {
                  originalMessage =
                      originalMessage
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
  Future<void> addCustomSuggestedQuestion(String question, String category) async {
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
        final cleanedMessages =
            conversation.messages.map((msg) {
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
                  originalMessage =
                      originalMessage
                          .split('\n\n--- Thông tin thời gian hiện tại ---')
                          .first;
                }

                // Remove user context if present
                if (originalMessage.contains('--- Thông tin người dùng ---')) {
                  originalMessage =
                      originalMessage
                          .split('\n\n--- Thông tin người dùng ---')
                          .first;
                }

                // Remove divination info if present
                if (originalMessage.contains(
                  '--- Thông tin chi tiết quẻ ---',
                )) {
                  originalMessage =
                      originalMessage
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
  }

  // Delete current conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final userId = await _resolveUserId();
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

  bool _isAllowedTopic(String text) {
  final normalized = _normalizeText(text);
  const keywords = [
    // --- La bàn phong thuỷ ---
    'la ban',
    'la ban phong thuy',
    'la ban bat trach',
    'la ban xuan khong',
    'la ban tam nguyen',
    'la kinh',
    'la kinh phong thuy',
    'kim chi nam',
    'kim chi bac',
    'cach doc la ban',
    'doc la ban',
    'su dung la ban',
    'do la ban',
    'do huong bang la ban',
    'la ban dien thoai',

    // --- Đo hướng / xác định hướng ---
    'do huong',
    'cach do huong',
    'huong nha',
    'huong nha nao tot',
    'huong nao tot',
    'huong nao xau',
    'huong tot',
    'huong xau',
    'huong hop tuoi',
    'huong hop menh',
    'huong may man',
    'huong nao hop',
    'huong cua chinh',
    'huong cong',
    'huong ban tho',
    'huong phong ngu',
    'huong bep',
    'vi tri bep',
    'xac dinh huong',
    'huong nao la tot',
    'huong nao nen tranh',

    // --- Tọa – hướng ---
    'toa huong',
    'toa bac huong nam',
    'toa tay huong dong',
    'toa tay bac huong dong nam',
    'toa huong nha',
    'toa huong cong',
    'toa huong ban tho',

    // --- Vị trí đặt đồ / bố trí ---
    'vi tri phong thuy',
    'vi tri nha',
    'vi tri cua',
    'vi tri cong',
    'vi tri ban tho',
    'vi tri bep',
    'dat ban tho',
    'dat bep',
    'dat giuong',
    'dat ban lam viec',
    'cach dat ban tho',
    'cach dat giuong',
    'cach dat ghe',
    'cach dat cong',

    // --- Kích thước / thước lỗ ban ---
    'kich thuoc phong thuy',
    'thuoc lo ban',
    'kich thuoc cua chinh',
    'kich thuoc ban tho',
    'kich thuoc cong',
    'kich thuoc bep',
    'thuoc lo ban 52',
    'thuoc lo ban 43',
    'thuoc lo ban 39',

    // --- Hướng tốt / xấu theo phong thuỷ ---
    'huong dai cat',
    'huong dai hung',
    'huong sinh khi',
    'huong thien y',
    'huong phuc vi',
    'huong ngu quy',
    'huong luc sat',
    'huong hoa hai',
    'huong tuyet menh',

    // --- Sai số / chỉnh hướng ---
    'sai so do huong',
    'do sai huong',
    'la ban bi nhieu',
    'chinh lai huong',
    'do huong bi lech',
    'kim chi quay sai',
    'meo do huong chuan',

    // --- Ứng dụng thực tế ---
    'xem huong mua nha',
    'xem huong chon dat',
    'xem huong sua nha',
    'xem huong mua can ho',
    'xem huong ban cong',
    'xem huong nha chung cu',
    'xem huong bep',
    'xem huong phong ngu',
    'xem huong cong',

    // --- Dạng câu hỏi thường gặp ---
    'nha toi huong nao',
    'do huong the nao',
    'dung la ban the nao',
    'toi nen dat ban tho huong nao',
    'dat giuong huong nao',
    'bep huong nao',
    'huong cong co xau khong',
    'huong x co tot khong',

    // --- Các từ bổ trợ thường xuất hiện ---
    'xem huong',
    'chinh huong',
    'tra huong',
    'dinh huong',
    'xoay la ban',
    'cach xoay la ban',
    'do bang dien thoai',
    'phong thuy nha cua',
    'phong thuy nha',
    'phong thuy van phong',
  ];

    return keywords.any(normalized.contains);
  }

  String _normalizeText(String input) {
    final buffer = StringBuffer();
    for (final unit in input.toLowerCase().codeUnits) {
      final char = String.fromCharCode(unit);
      buffer.write(_diacriticMap[char] ?? char);
    }
    return buffer.toString();
  }
}

const Map<String, String> _diacriticMap = {
  'à': 'a',
  'á': 'a',
  'ả': 'a',
  'ã': 'a',
  'ạ': 'a',
  'â': 'a',
  'ầ': 'a',
  'ấ': 'a',
  'ẩ': 'a',
  'ẫ': 'a',
  'ậ': 'a',
  'ă': 'a',
  'ằ': 'a',
  'ắ': 'a',
  'ẳ': 'a',
  'ẵ': 'a',
  'ặ': 'a',
  'À': 'a',
  'Á': 'a',
  'Ả': 'a',
  'Ã': 'a',
  'Ạ': 'a',
  'Â': 'a',
  'Ầ': 'a',
  'Ấ': 'a',
  'Ẩ': 'a',
  'Ẫ': 'a',
  'Ậ': 'a',
  'Ă': 'a',
  'Ằ': 'a',
  'Ắ': 'a',
  'Ẳ': 'a',
  'Ẵ': 'a',
  'Ặ': 'a',
  'đ': 'd',
  'Đ': 'd',
  'è': 'e',
  'é': 'e',
  'ẻ': 'e',
  'ẽ': 'e',
  'ẹ': 'e',
  'ê': 'e',
  'ề': 'e',
  'ế': 'e',
  'ể': 'e',
  'ễ': 'e',
  'ệ': 'e',
  'È': 'e',
  'É': 'e',
  'Ẻ': 'e',
  'Ẽ': 'e',
  'Ẹ': 'e',
  'Ê': 'e',
  'Ề': 'e',
  'Ế': 'e',
  'Ể': 'e',
  'Ễ': 'e',
  'Ệ': 'e',
  'ì': 'i',
  'í': 'i',
  'ỉ': 'i',
  'ĩ': 'i',
  'ị': 'i',
  'Ì': 'i',
  'Í': 'i',
  'Ỉ': 'i',
  'Ĩ': 'i',
  'Ị': 'i',
  'ò': 'o',
  'ó': 'o',
  'ỏ': 'o',
  'õ': 'o',
  'ọ': 'o',
  'ô': 'o',
  'ồ': 'o',
  'ổ': 'o',
  'ố': 'o',
  'ỗ': 'o',
  'ộ': 'o',
  'ơ': 'o',
  'ờ': 'o',
  'ở': 'o',
  'ớ': 'o',
  'ỡ': 'o',
  'ợ': 'o',
  'Ò': 'o',
  'Ó': 'o',
  'Ỏ': 'o',
  'Õ': 'o',
  'Ọ': 'o',
  'Ô': 'o',
  'Ồ': 'o',
  'Ổ': 'o',
  'Ố': 'o',
  'Ỗ': 'o',
  'Ộ': 'o',
  'Ơ': 'o',
  'Ờ': 'o',
  'Ở': 'o',
  'Ớ': 'o',
  'Ỡ': 'o',
  'Ợ': 'o',
  'ù': 'u',
  'ú': 'u',
  'ủ': 'u',
  'ũ': 'u',
  'ụ': 'u',
  'ư': 'u',
  'ừ': 'u',
  'ứ': 'u',
  'ử': 'u',
  'ữ': 'u',
  'ự': 'u',
  'Ù': 'u',
  'Ú': 'u',
  'Ủ': 'u',
  'Ũ': 'u',
  'Ụ': 'u',
  'Ư': 'u',
  'Ừ': 'u',
  'Ứ': 'u',
  'Ử': 'u',
  'Ữ': 'u',
  'Ự': 'u',
  'ỳ': 'y',
  'ý': 'y',
  'ỷ': 'y',
  'ỹ': 'y',
  'ỵ': 'y',
  'Ỳ': 'y',
  'Ý': 'y',
  'Ỷ': 'y',
  'Ỹ': 'y',
  'Ỵ': 'y',
};
