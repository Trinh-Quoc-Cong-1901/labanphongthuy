import '../models/direction_info.dart';
import '../models/feng_shui_result.dart';

class FengShuiCalculator {
  static FengShuiCalculator? _instance;
  static FengShuiCalculator get instance => _instance ??= FengShuiCalculator._internal();
  
  FengShuiCalculator._internal();

  /// Calculate complete feng shui result for a person
  FengShuiResult calculateFengShuiResult(int birthYear, bool isMale) {
    final personalInfo = PersonalInfo.calculate(birthYear, isMale);
    final directions = _calculateDirectionsForKua(personalInfo.kuaNumber);
    
    return FengShuiResult(
      personalInfo: personalInfo,
      directions: directions,
    );
  }

  /// Calculate 8 directions for specific Kua number
  List<FengShuiDirectionResult> _calculateDirectionsForKua(int kuaNumber) {
    final Map<BaGuaDirection, FengShuiDirectionType> directionMapping = 
        _getDirectionMappingForKua(kuaNumber);
    
    final List<FengShuiDirectionResult> results = [];
    
    for (final entry in directionMapping.entries) {
      final directionData = _getDirectionData(entry.value);
      results.add(
        FengShuiDirectionResult(
          direction: entry.key,
          type: entry.value,
          name: directionData['name']!,
          description: directionData['description']!,
          isGood: directionData['isGood'] as bool,
          priority: directionData['priority'] as int,
        ),
      );
    }
    
    return results;
  }

  /// Get direction mapping for each Kua number
  Map<BaGuaDirection, FengShuiDirectionType> _getDirectionMappingForKua(int kuaNumber) {
    switch (kuaNumber) {
      case 1: // Khảm - VERIFIED with standard document
        return {
          BaGuaDirection.ton: FengShuiDirectionType.sinhKhi,        // Đông Nam - Sinh khí ✓
          BaGuaDirection.chan: FengShuiDirectionType.thienY,        // Đông - Thiên Y ✓ (FIXED)
          BaGuaDirection.ly: FengShuiDirectionType.dienNien,        // Nam - Phúc Đức ✓ (FIXED)
          BaGuaDirection.kham: FengShuiDirectionType.phucVi,        // Bắc - Phục vị ✓ (FIXED)
          BaGuaDirection.can: FengShuiDirectionType.nguQuy,         // Đông Bắc - Ngũ quỷ ✓ (FIXED)
          BaGuaDirection.kien: FengShuiDirectionType.lucSat,        // Tây Bắc - Lục sát ✓ (FIXED)
          BaGuaDirection.doai: FengShuiDirectionType.hoaHai,        // Tây - Họa hại ✓ (FIXED)
          BaGuaDirection.khon: FengShuiDirectionType.tuyetMenh,     // Tây Nam - Tuyệt mệnh ✓ (FIXED)
        };
      case 2: // Khôn - FIXED according to official document
        return {
          BaGuaDirection.can: FengShuiDirectionType.sinhKhi,       // Đông Bắc - Sinh khí (Tốt nhất)
          BaGuaDirection.doai: FengShuiDirectionType.thienY,       // Tây - Thiên Y (Tốt)
          BaGuaDirection.kien: FengShuiDirectionType.dienNien,     // Tây Bắc - Phúc Đức (Tốt)
          BaGuaDirection.khon: FengShuiDirectionType.phucVi,       // Tây Nam - Phục vị (Tốt)
          BaGuaDirection.ton: FengShuiDirectionType.nguQuy,        // Đông Nam - Ngũ quỷ (Xấu)
          BaGuaDirection.ly: FengShuiDirectionType.lucSat,         // Nam - Lục sát (Xấu)
          BaGuaDirection.chan: FengShuiDirectionType.hoaHai,       // Đông - Họa hại (Xấu)
          BaGuaDirection.kham: FengShuiDirectionType.tuyetMenh,    // Bắc - Tuyệt mệnh (Rất xấu)
        };
      case 3: // Chấn - VERIFIED with standard document
        return {
          BaGuaDirection.ly: FengShuiDirectionType.sinhKhi,        // Nam - Sinh khí ✓
          BaGuaDirection.kham: FengShuiDirectionType.thienY,       // Bắc - Thiên Y ✓
          BaGuaDirection.ton: FengShuiDirectionType.dienNien,      // Đông Nam - Phúc Đức ✓
          BaGuaDirection.chan: FengShuiDirectionType.phucVi,       // Đông - Phục vị ✓
          BaGuaDirection.kien: FengShuiDirectionType.nguQuy,       // Tây Bắc - Ngũ quỷ ✓ (FIXED)
          BaGuaDirection.can: FengShuiDirectionType.lucSat,        // Đông Bắc - Lục sát ✓ (FIXED) 
          BaGuaDirection.khon: FengShuiDirectionType.hoaHai,       // Tây Nam - Họa hại ✓ (FIXED)
          BaGuaDirection.doai: FengShuiDirectionType.tuyetMenh,    // Tây - Tuyệt mệnh ✓
        };
      case 4: // Tốn - VERIFIED with standard document
        return {
          BaGuaDirection.kham: FengShuiDirectionType.sinhKhi,      // Bắc - Sinh khí ✓
          BaGuaDirection.ly: FengShuiDirectionType.thienY,         // Nam - Thiên Y ✓ (FIXED)
          BaGuaDirection.chan: FengShuiDirectionType.dienNien,     // Đông - Phúc Đức ✓ (FIXED)
          BaGuaDirection.ton: FengShuiDirectionType.phucVi,        // Đông Nam - Phục vị ✓
          BaGuaDirection.khon: FengShuiDirectionType.nguQuy,       // Tây Nam - Ngũ quỷ ✓ (FIXED)
          BaGuaDirection.doai: FengShuiDirectionType.lucSat,       // Tây - Lục sát ✓
          BaGuaDirection.kien: FengShuiDirectionType.hoaHai,       // Tây Bắc - Họa hại ✓ (FIXED)
          BaGuaDirection.can: FengShuiDirectionType.tuyetMenh,     // Đông Bắc - Tuyệt mệnh ✓
        };
      case 6: // Càn - VERIFIED with standard document
        return {
          BaGuaDirection.doai: FengShuiDirectionType.sinhKhi,      // Tây - Sinh khí ✓
          BaGuaDirection.can: FengShuiDirectionType.thienY,        // Đông Bắc - Thiên Y ✓
          BaGuaDirection.khon: FengShuiDirectionType.dienNien,     // Tây Nam - Phúc Đức ✓
          BaGuaDirection.kien: FengShuiDirectionType.phucVi,       // Tây Bắc - Phục vị ✓
          BaGuaDirection.chan: FengShuiDirectionType.nguQuy,       // Đông - Ngũ quỷ ✓ (FIXED)
          BaGuaDirection.kham: FengShuiDirectionType.lucSat,       // Bắc - Lục sát ✓
          BaGuaDirection.ton: FengShuiDirectionType.hoaHai,        // Đông Nam - Họa hại ✓ (FIXED)
          BaGuaDirection.ly: FengShuiDirectionType.tuyetMenh,      // Nam - Tuyệt mệnh ✓ (FIXED)
        };
      case 7: // Đoài - VERIFIED with standard document
        return {
          BaGuaDirection.kien: FengShuiDirectionType.sinhKhi,      // Tây Bắc - Sinh khí ✓
          BaGuaDirection.khon: FengShuiDirectionType.thienY,       // Tây Nam - Thiên Y ✓
          BaGuaDirection.can: FengShuiDirectionType.dienNien,      // Đông Bắc - Phúc Đức ✓
          BaGuaDirection.doai: FengShuiDirectionType.phucVi,       // Tây - Phục vị ✓
          BaGuaDirection.ly: FengShuiDirectionType.nguQuy,         // Nam - Ngũ quỷ ✓ (FIXED)
          BaGuaDirection.ton: FengShuiDirectionType.lucSat,        // Đông Nam - Lục sát ✓ (FIXED)
          BaGuaDirection.kham: FengShuiDirectionType.hoaHai,       // Bắc - Họa hại ✓
          BaGuaDirection.chan: FengShuiDirectionType.tuyetMenh,    // Đông - Tuyệt mệnh ✓ (FIXED)
        };
      case 8: // Cấn - VERIFIED with standard document
        return {
          BaGuaDirection.khon: FengShuiDirectionType.sinhKhi,      // Tây Nam - Sinh khí ✓
          BaGuaDirection.kien: FengShuiDirectionType.thienY,       // Tây Bắc - Thiên Y ✓ (FIXED)
          BaGuaDirection.doai: FengShuiDirectionType.dienNien,     // Tây - Phúc Đức ✓ (FIXED)
          BaGuaDirection.can: FengShuiDirectionType.phucVi,        // Đông Bắc - Phục vị ✓
          BaGuaDirection.kham: FengShuiDirectionType.nguQuy,       // Bắc - Ngũ quỷ ✓
          BaGuaDirection.chan: FengShuiDirectionType.lucSat,       // Đông - Lục sát ✓
          BaGuaDirection.ly: FengShuiDirectionType.hoaHai,         // Nam - Họa hại ✓ (FIXED)
          BaGuaDirection.ton: FengShuiDirectionType.tuyetMenh,     // Đông Nam - Tuyệt mệnh ✓ (FIXED)
        };
      case 9: // Ly - VERIFIED with standard document
        return {
          BaGuaDirection.chan: FengShuiDirectionType.sinhKhi,      // Đông - Sinh khí ✓
          BaGuaDirection.ton: FengShuiDirectionType.thienY,        // Đông Nam - Thiên Y ✓
          BaGuaDirection.kham: FengShuiDirectionType.dienNien,     // Bắc - Phúc Đức ✓
          BaGuaDirection.ly: FengShuiDirectionType.phucVi,         // Nam - Phục vị ✓
          BaGuaDirection.doai: FengShuiDirectionType.nguQuy,       // Tây - Ngũ quỷ ✓
          BaGuaDirection.khon: FengShuiDirectionType.lucSat,       // Tây Nam - Lục sát ✓ (FIXED)
          BaGuaDirection.can: FengShuiDirectionType.hoaHai,        // Đông Bắc - Họa hại ✓
          BaGuaDirection.kien: FengShuiDirectionType.tuyetMenh,    // Tây Bắc - Tuyệt mệnh ✓ (FIXED)
        };
      default:
        throw ArgumentError('Invalid Kua number: $kuaNumber');
    }
  }

  /// Get direction data with name, description, and properties
  Map<String, dynamic> _getDirectionData(FengShuiDirectionType type) {
    switch (type) {
      case FengShuiDirectionType.sinhKhi:
        return {
          'name': 'Sinh Khí',
          'description': 'Thượng cát - Hướng tốt nhất, mang lại thành công, tài lộc và sức khỏe',
          'isGood': true,
          'priority': 1,
        };
      case FengShuiDirectionType.dienNien:
        return {
          'name': 'Phúc Đức',
          'description': 'Thượng cát - Mang lại tuổi thọ, hạnh phúc gia đình và mối quan hệ tốt',
          'isGood': true,
          'priority': 2,
        };
      case FengShuiDirectionType.thienY:
        return {
          'name': 'Thiên Y',
          'description': 'Trung cát - Hỗ trợ sức khỏe, chữa bệnh và có quý nhân giúp đỡ',
          'isGood': true,
          'priority': 3,
        };
      case FengShuiDirectionType.phucVi:
        return {
          'name': 'Phục Vị',
          'description': 'Tiểu cát - Mang lại bình an, ổn định và phát triển từ từ',
          'isGood': true,
          'priority': 4,
        };
      case FengShuiDirectionType.hoaHai:
        return {
          'name': 'Họa Hại',
          'description': 'Tiểu hung - Gây tranh cãi, mâu thuẫn trong gia đình và công việc',
          'isGood': false,
          'priority': 5,
        };
      case FengShuiDirectionType.lucSat:
        return {
          'name': 'Lục Sát',
          'description': 'Trung hung - Gây tổn thất tài chính, pháp lý và mối quan hệ',
          'isGood': false,
          'priority': 6,
        };
      case FengShuiDirectionType.nguQuy:
        return {
          'name': 'Ngũ Quỷ',
          'description': 'Thượng hung - Gây tai nạn, hỏa hoạn, trộm cắp và bệnh tật',
          'isGood': false,
          'priority': 7,
        };
      case FengShuiDirectionType.tuyetMenh:
        return {
          'name': 'Tuyệt Mệnh',
          'description': 'Thượng hung - Hướng xấu nhất, gây tổn hại nghiêm trọng đến sức khỏe và tài sản',
          'isGood': false,
          'priority': 8,
        };
    }
  }

  /// Get recommended actions for good directions
  List<String> getRecommendationsForDirection(FengShuiDirectionType type) {
    switch (type) {
      case FengShuiDirectionType.sinhKhi:
        return [
          'Đặt cửa chính, phòng ngủ chủ ở hướng này',
          'Làm việc quay mặt về hướng này',
          'Đầu giường hướng về đây khi ngủ',
        ];
      case FengShuiDirectionType.dienNien:
        return [
          'Phù hợp cho phòng khách, phòng ăn',
          'Tốt cho các hoạt động giao lưu, họp mặt',
          'Hướng tốt cho người cao tuổi',
        ];
      case FengShuiDirectionType.thienY:
        return [
          'Đặt phòng ngủ người bệnh ở hướng này',
          'Phù hợp cho phòng thuốc, phòng thiền',
          'Hướng tốt khi cần hồi phục sức khỏe',
        ];
      case FengShuiDirectionType.phucVi:
        return [
          'Phù hợp cho phòng làm việc, học tập',
          'Tốt cho các hoạt động tĩnh, cần sự tập trung',
          'Hướng ổn định cho cuộc sống lâu dài',
        ];
      default:
        return [
          'Tránh đặt cửa chính, phòng ngủ ở hướng này',
          'Không nên ngồi làm việc quay lưng về hướng này',
          'Tránh các hoạt động quan trọng ở hướng này',
        ];
    }
  }
}