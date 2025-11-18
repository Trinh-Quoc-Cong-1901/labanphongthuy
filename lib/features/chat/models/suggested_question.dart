import 'package:equatable/equatable.dart';

class SuggestedQuestion extends Equatable {
  final String id;
  final String question;
  final String category;

  const SuggestedQuestion({
    required this.id,
    required this.question,
    required this.category,
  });

  factory SuggestedQuestion.fromJson(Map<String, dynamic> json) {
    return SuggestedQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [id, question, category];
}

// Predefined categories for suggested questions - Feng Shui specific
enum QuestionCategory {
  laBan,        // La bàn & Hướng
  nhaO,         // Phong thủy nhà ở
  vanPhong,     // Phong thủy văn phòng
  mauSac,       // Màu sắc may mắn
  ngayTot,      // Ngày tốt/xấu
  tongQuat,     // Tổng quát (general questions)
}

// Extension to get display name
extension QuestionCategoryExtension on QuestionCategory {
  String get displayName {
    switch (this) {
      case QuestionCategory.laBan:
        return 'La bàn & Hướng';
      case QuestionCategory.nhaO:
        return 'Phong thủy nhà ở';
      case QuestionCategory.vanPhong:
        return 'Phong thủy văn phòng';
      case QuestionCategory.mauSac:
        return 'Màu sắc may mắn';
      case QuestionCategory.ngayTot:
        return 'Ngày tốt/xấu';
      case QuestionCategory.tongQuat:
        return 'Tổng quát';
    }
  }

  String get name {
    switch (this) {
      case QuestionCategory.laBan:
        return 'laBan';
      case QuestionCategory.nhaO:
        return 'nhaO';
      case QuestionCategory.vanPhong:
        return 'vanPhong';
      case QuestionCategory.mauSac:
        return 'mauSac';
      case QuestionCategory.ngayTot:
        return 'ngayTot';
      case QuestionCategory.tongQuat:
        return 'tongQuat';
    }
  }
}