import 'dart:math';

class ChatAIService {
  // Mock AI responses for feng shui consultation
  final List<String> _mockResponses = [
    'Theo phong thủy, điều quan trọng nhất là tạo ra sự cân bằng và hài hòa trong không gian sống của bạn.',
    'Tôi khuyên bạn nên đặt gương sao cho không phản chiếu trực tiếp giường ngủ, điều này có thể ảnh hưởng đến giấc ngủ.',
    'Màu xanh lá cây và xanh dương rất tốt cho hướng Đông và Đông Nam theo ngũ hành phong thủy.',
    'Hãy đảm bảo lối vào nhà luôn sạch sẽ và thoáng đãng để thu hút tài lộc và may mắn.',
    'Theo tuổi của bạn, tôi có thể tư vấn cụ thể hơn về hướng ngủ và màu sắc phù hợp. Bạn sinh năm nao?',
    'Cây xanh trong nhà không chỉ làm đẹp không gian mà còn giúp tăng khí tích cực theo phong thủy.',
    'Phòng bếp không nên đặt trực diện với cửa chính, điều này có thể làm tài lộc "chảy" ra ngoài.',
    'Hướng giường ngủ rất quan trọng. Hãy cho tôi biết tuổi của bạn để tư vấn hướng tốt nhất.',
  ];

  final List<String> _greetingResponses = [
    'Chào bạn! Tôi là Phong Vân, chuyên gia phong thủy AI. Tôi có thể giúp gì cho bạn?',
    'Xin chào! Hôm nay bạn cần tư vấn gì về phong thủy không?',
    'Chào mừng! Tôi sẵn sàng hỗ trợ bạn về các vấn đề phong thủy.',
  ];

  final List<String> _compassRelatedResponses = [
    'La bàn phong thủy rất quan trọng để xác định hướng tốt nhất cho ngôi nhà và đồ đạc của bạn.',
    'Với la bàn, bạn có thể xác định chính xác 8 hướng cơ bản và áp dụng lý thuyết ngũ hành.',
    'Dùng la bàn để đo hướng nhà, sau đó tôi có thể tư vấn cách bố trí nội thất phù hợp.',
    'La bàn theo tuổi sẽ giúp bạn tìm ra hướng cát lành dựa trên năm sinh và bát quái cá nhân.',
  ];

  Future<String> sendMessage(String userMessage) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1200)));

    final message = userMessage.toLowerCase();

    // Check for greetings
    if (_isGreeting(message)) {
      return _getRandomResponse(_greetingResponses);
    }

    // Check for compass related questions
    if (_isCompassRelated(message)) {
      return _getRandomResponse(_compassRelatedResponses);
    }

    // Check for age related questions
    if (_isAgeRelated(message)) {
      return 'Dựa trên tuổi của bạn, tôi có thể tư vấn hướng ngủ, hướng làm việc và màu sắc may mắn. Năm sinh của bạn thuộc mệnh gì trong ngũ hành?';
    }

    // Check for house/home related questions
    if (_isHomeRelated(message)) {
      return 'Về nhà ở, điều quan trọng là hướng cửa chính, vị trí phòng ngủ và phòng bếp. Bạn có thể mô tả sơ lược về căn nhà hiện tại không?';
    }

    // Return a random general response
    return _getRandomResponse(_mockResponses);
  }

  bool _isGreeting(String message) {
    final greetingKeywords = [
      'xin chào',
      'chào',
      'hello',
      'hi',
      'chào bạn',
      'xin chao'
    ];
    return greetingKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isCompassRelated(String message) {
    final compassKeywords = [
      'la bàn',
      'la ban',
      'compass',
      'hướng',
      'đông',
      'tây',
      'nam',
      'bắc'
    ];
    return compassKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isAgeRelated(String message) {
    final ageKeywords = ['tuổi', 'sinh', 'năm sinh', 'mệnh', 'bát quái'];
    return ageKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isHomeRelated(String message) {
    final homeKeywords = [
      'nhà',
      'phòng',
      'cửa',
      'giường',
      'bếp',
      'toilet',
      'phòng ngủ',
      'phòng khách'
    ];
    return homeKeywords.any((keyword) => message.contains(keyword));
  }

  String _getRandomResponse(List<String> responses) {
    return responses[Random().nextInt(responses.length)];
  }
}
