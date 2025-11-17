import 'dart:math';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../../../services/api_provider.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/suggested_question.dart';
import '../../../utils/logger_utils.dart';

class ChatService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    print('ChatService initialized');
    // Don't call init() here - it will be called asynchronously
  }

  @override
  void onReady() {
    super.onReady();
    print('ChatService is ready');
  }

  // >>> START NEW METHOD - getAiCompletionForPrompt
  /// Gửi một prompt đến AI và chỉ trả về nội dung phản hồi của AI.
  /// Không lưu cuộc hội thoại này vào lịch sử chat chính thức.
  Future<String> getAiCompletionForPrompt({
    required String prompt,
    String model = 'openai', // Model mặc định - match lich-am exactly
    String tempUserId = 'prompt_only_user', // ID người dùng tạm thời
  }) async {
    print("ChatService: getAiCompletionForPrompt called with prompt: ${prompt.substring(0, min(50, prompt.length))}...");
    try {
      final Map<String, dynamic> data = {
        'message': prompt,
        'model': model,
        'userId': tempUserId, // Sử dụng một userId tạm thời, không nên trùng với userId thật
        // 'conversationId': null, // Luôn tạo conversation mới cho mục đích này
      };

      final response = await _apiProvider.post('/api/chat', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true &&
            responseData['responseObject'] != null) {
          final conversation =
              Conversation.fromJson(responseData['responseObject']);

          // Lấy message cuối cùng từ assistant
          if (conversation.messages.isNotEmpty) {
            // >>> START MODIFICATION
            ChatMessage? lastAssistantMessage;
            for (int i = conversation.messages.length - 1; i >= 0; i--) {
              if (conversation.messages[i].role == MessageRole.assistant &&
                  !conversation.messages[i].isLoading) {
                lastAssistantMessage = conversation.messages[i];
                break;
              }
            }
            // >>> END MODIFICATION
            if (lastAssistantMessage != null) {
              print("ChatService: AI completion received successfully.");
              return lastAssistantMessage.content;
            }
          }
          print("ChatService: AI response parsed, but no assistant message found.");
          return "Lão Đại AI không có phản hồi cho yêu cầu này.";
        } else {
          print("ChatService: AI API call was not successful. Message: ${responseData['message']}");
          return "Lỗi từ Lão Đại AI: ${responseData['message'] ?? 'Không rõ lỗi'}";
        }
      }
      print("ChatService: AI API call failed with status code ${response.statusCode}. Body: ${response.data}");
      return "Lỗi kết nối đến Lão Đại AI (Code: ${response.statusCode}).";
    } catch (e, stackTrace) {
      print('ChatService: Exception in getAiCompletionForPrompt: $e\n$stackTrace');
      return "Đã xảy ra lỗi khi giao tiếp với Lão Đại AI: ${e.toString()}";
    }
  }
  // >>> END NEW METHOD - getAiCompletionForPrompt

  // Use getter to always get ApiProvider from GetX instead of late field
  ApiProvider get _apiProvider => Get.find<ApiProvider>();
  final Uuid _uuid = const Uuid();

  // Map to store conversations in memory (replace with local storage later)
  final Map<String, List<Conversation>> _conversations = {};
  final Map<String, List<SuggestedQuestion>> _suggestedQuestions = {};

  // Singleton pattern
  static ChatService get to => Get.find<ChatService>();

  Future<ChatService> init() async {
    // ApiProvider is now accessed via getter, no need to initialize here

    // Initialize suggested questions if they don't exist
    if (_suggestedQuestions.isEmpty) {
      await _initializeSuggestedQuestions();
    }

    return this;
  }

  // Initialize default suggested questions
  Future<void> _initializeSuggestedQuestions() async {
    final List<SuggestedQuestion> questions = [
      // La bàn & Hướng
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Hướng nào tốt nhất cho cửa chính của ngôi nhà?',
        category: QuestionCategory.laBan.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Cách sử dụng la bàn để xác định hướng giường ngủ?',
        category: QuestionCategory.laBan.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Hướng Đông có phù hợp với tuổi của tôi không?',
        category: QuestionCategory.laBan.name,
      ),

      // Phong thủy nhà ở
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Cách bố trí phòng khách theo phong thủy?',
        category: QuestionCategory.nhaO.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Vị trí đặt gương trong nhà như thế nào cho tốt?',
        category: QuestionCategory.nhaO.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Phòng bếp nên đặt ở hướng nào?',
        category: QuestionCategory.nhaO.name,
      ),

      // Phong thủy văn phòng
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Hướng ngồi làm việc nào mang lại may mắn?',
        category: QuestionCategory.vanPhong.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Cách bố trí bàn làm việc để thu hút tài lộc?',
        category: QuestionCategory.vanPhong.name,
      ),

      // Màu sắc may mắn
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Màu sắc may mắn cho người sinh năm 1990?',
        category: QuestionCategory.mauSac.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Màu nào tốt cho phòng ngủ theo phong thủy?',
        category: QuestionCategory.mauSac.name,
      ),

      // Ngày tốt
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Ngày nào trong tuần tốt để chuyển nhà?',
        category: QuestionCategory.ngayTot.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Cách chọn ngày tốt để mở cửa hàng kinh doanh?',
        category: QuestionCategory.ngayTot.name,
      ),

      // Tổng quát
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Cây xanh nào tốt để trồng trong nhà?',
        category: QuestionCategory.tongQuat.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Những điều cần tránh trong phong thủy nhà ở?',
        category: QuestionCategory.tongQuat.name,
      ),
      SuggestedQuestion(
        id: _uuid.v4(),
        question: 'Phong thủy có thể giúp cải thiện sức khỏe như thế nào?',
        category: QuestionCategory.tongQuat.name,
      ),
    ];

    // Save to memory storage (replace with persistent storage later)
    _suggestedQuestions['default'] = questions;
  }

  // Get suggested questions
  List<SuggestedQuestion> getSuggestedQuestions({String? category}) {
    final allQuestions = _suggestedQuestions['default'] ?? [];

    if (category != null) {
      return allQuestions.where((q) => q.category == category).toList();
    }

    return allQuestions;
  }

  // Get suggested questions by category
  Map<String, List<SuggestedQuestion>> getSuggestedQuestionsByCategory() {
    final allQuestions = getSuggestedQuestions();
    final Map<String, List<SuggestedQuestion>> categorizedQuestions = {};

    for (final question in allQuestions) {
      categorizedQuestions.putIfAbsent(question.category, () => []);
      categorizedQuestions[question.category]!.add(question);
    }

    return categorizedQuestions;
  }

  // Add a custom suggested question
  Future<void> addSuggestedQuestion(String question, String category) async {
    final newQuestion = SuggestedQuestion(
      id: _uuid.v4(),
      question: question,
      category: category,
    );

    final existingList = getSuggestedQuestions();
    existingList.add(newQuestion);
    _suggestedQuestions['default'] = existingList;
  }

  // Get all conversations for a user
  List<Conversation> getAllConversations(String userId) {
    final conversations = _conversations[userId] ?? [];

    // Sort conversations by updatedAt in descending order (newest first)
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return conversations;
  }

  // Get a specific conversation
  Conversation? getConversation(String userId, String conversationId) {
    final conversations = getAllConversations(userId);
    return conversations.firstWhereOrNull((conv) => conv.id == conversationId);
  }

  // Save a conversation
  Future<void> saveConversation(String userId, Conversation conversation) async {
    final List<Conversation> conversations = getAllConversations(userId);

    // Check if conversation already exists
    final index = conversations.indexWhere((conv) => conv.id == conversation.id);
    if (index >= 0) {
      // Update existing conversation
      conversations[index] = conversation;
    } else {
      // Add new conversation
      conversations.add(conversation);
    }

    _conversations[userId] = conversations;
  }

  // Delete a conversation
  Future<void> deleteConversation(String userId, String conversationId) async {
    final List<Conversation> conversations = getAllConversations(userId);
    conversations.removeWhere((conv) => conv.id == conversationId);
    _conversations[userId] = conversations;
  }

  // Clear all conversations for a user
  Future<void> clearAllConversations(String userId) async {
    _conversations[userId] = [];
  }

  // Get available AI models
  Future<List<Map<String, dynamic>>> getAvailableModels() async {
    try {
      final response = await _apiProvider.get('/api/models');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['responseObject'] != null) {
          final responseList = data['responseObject'] as List;
          return responseList
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Failed to get available models: $e');
      // Default models if API fails - COPY EXACT FROM LICH-AM
      return [
        {'id': 'openai', 'name': 'gpt-3.5-turbo', 'maxContextLength': 4096},
        {'id': 'gemini', 'name': 'gemini-2.0-flash', 'maxContextLength': 30000}
      ];
    }
  }

  // Send a message to the AI
  Future<Conversation> sendMessage({
    required String userId,
    required String message,
    required String model,
    String? conversationId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'message': message,
        'model': 'lao_dai', // HARDCODED like lich-am line 349
        'userId': userId,
      };

      if (conversationId != null) {
        data['conversationId'] = conversationId;
      }

      final response = await _apiProvider.post('/api/chat', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true &&
            responseData['responseObject'] != null) {
          final conversation = Conversation.fromJson(responseData['responseObject']);

          // Save to local storage
          await saveConversation(userId, conversation);

          return conversation;
        } else {
          // Server returned 200 but with success: false
          final errorMessage = responseData['message'] ?? 'Lỗi không xác định từ server';
          return await _createLocalErrorConversation(userId, message, model, conversationId,
              errorType: 'server_error', errorMessage: errorMessage);
        }
      } else {
        // Server returned non-200 status code
        return await _createLocalErrorConversation(userId, message, model, conversationId,
            errorType: 'server_error', errorMessage: 'Server trả về lỗi ${response.statusCode}');
      }
    } catch (e) {
      LoggerUtils.error('Failed to send message', e);

      // Determine error type
      String errorType = 'unknown_error';
      String errorMessage = 'Lỗi không xác định';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.connectionError:
            errorType = 'network_error';
            errorMessage = 'Không có kết nối mạng. Vui lòng kiểm tra Wi-Fi hoặc dữ liệu di động và thử lại.';
            break;
          case DioExceptionType.badResponse:
            if (e.response?.statusCode == 500) {
              errorType = 'server_error';
              errorMessage = 'Server đang gặp sự cố (lỗi 500). Vui lòng thử lại sau.';
            } else {
              errorType = 'server_error';
              errorMessage = 'Server trả về lỗi ${e.response?.statusCode ?? "không xác định"}';
            }
            break;
          case DioExceptionType.cancel:
            errorType = 'cancelled';
            errorMessage = 'Yêu cầu đã bị hủy';
            break;
          case DioExceptionType.unknown:
          default:
            errorType = 'unknown_error';
            errorMessage = 'Lỗi không xác định: ${e.message}';
            break;
        }
      }

      // Create local conversation with specific error message
      return await _createLocalErrorConversation(userId, message, model, conversationId,
          errorType: errorType, errorMessage: errorMessage);
    }
  }

  // Helper to create a local conversation with error message
  Future<Conversation> _createLocalErrorConversation(
      String userId,
      String message,
      String model,
      String? conversationId, {
      required String errorType,
      required String errorMessage,
    }) async {
    final now = DateTime.now();
    final String newConvId = conversationId ?? _uuid.v4();

    // Get the existing conversation if it exists
    Conversation? existingConversation;
    if (conversationId != null) {
      existingConversation = getConversation(userId, conversationId);
    }

    final List<ChatMessage> messages = existingConversation?.messages.toList() ?? [];

    // Add user message if it doesn't already exist
    if (!messages.any((msg) => msg.content == message && msg.role == MessageRole.user)) {
      messages.add(ChatMessage(
        id: _uuid.v4(),
        content: message,
        role: MessageRole.user,
        timestamp: now,
        status: MessageStatus.sent,
      ));
    }

    // Add assistant error message with appropriate error message
    messages.add(ChatMessage(
      id: _uuid.v4(),
      content: errorMessage,
      role: MessageRole.assistant,
      timestamp: now.add(const Duration(seconds: 1)),
    ));

    final conversation = Conversation(
      id: newConvId,
      title: _generateTitle(message),
      messages: messages,
      model: model,
      userId: userId,
      createdAt: existingConversation?.createdAt ?? now,
      updatedAt: now,
    );

    // Save the conversation to local storage
    await saveConversation(userId, conversation);

    return conversation;
  }

  // Generate a title for a new conversation
  String _generateTitle(String message) {
    // Use the first 5 words of the message or fewer if the message is shorter
    final words = message.split(' ');
    if (words.length <= 5) {
      return message;
    }
    return '${words.take(5).join(' ')}...';
  }


}
