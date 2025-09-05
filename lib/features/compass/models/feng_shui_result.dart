import 'package:equatable/equatable.dart';
import 'direction_info.dart';

enum FengShuiDirectionType {
  sinhKhi,      // Sinh khí - Thượng cát
  dienNien,     // Diên niên (Phúc Đức) - Thượng cát  
  thienY,       // Thiên Y - Trung cát
  phucVi,       // Phục vị - Tiểu cát
  hoaHai,       // Họa hại - Tiểu hung
  lucSat,       // Lục sát - Trung hung
  nguQuy,       // Ngũ quỷ - Thượng hung
  tuyetMenh,    // Tuyệt mệnh - Thượng hung
}

enum PersonalDestinyGroup {
  dongTu,   // Đông Tứ (1,3,4,9)
  tayTu,    // Tây Tứ (2,6,7,8)
}

class PersonalInfo extends Equatable {
  final int birthYear;
  final bool isMale;
  final int kuaNumber;
  final PersonalDestinyGroup destinyGroup;

  const PersonalInfo({
    required this.birthYear,
    required this.isMale,
    required this.kuaNumber,
    required this.destinyGroup,
  });

  factory PersonalInfo.calculate(int birthYear, bool isMale) {
    // CORRECT FORMULA: Only use last 2 digits
    final lastTwoDigits = birthYear % 100;
    final tensDigit = lastTwoDigits ~/ 10;
    final onesDigit = lastTwoDigits % 10;
    
    // Sum last 2 digits
    int sum = tensDigit + onesDigit;
    
    // Reduce to single digit if needed
    while (sum > 9) {
      sum = (sum ~/ 10) + (sum % 10);
    }
    
    int kuaNumber;
    if (birthYear < 2000) {
      // Formula for birth year BEFORE 2000
      if (isMale) {
        kuaNumber = 10 - sum;
        if (kuaNumber == 5) kuaNumber = 2; // Male 5 -> 2
      } else {
        kuaNumber = 5 + sum;
        if (kuaNumber > 9) kuaNumber -= 9;
        if (kuaNumber == 5) kuaNumber = 8; // Female 5 -> 8
      }
    } else {
      // Formula for birth year FROM 2000 onwards
      if (isMale) {
        kuaNumber = 9 - sum;
        if (kuaNumber == 5) kuaNumber = 2; // Male 5 -> 2
        if (kuaNumber <= 0) kuaNumber += 9; // Handle negative
      } else {
        kuaNumber = 6 + sum;
        if (kuaNumber > 9) kuaNumber -= 9;
        if (kuaNumber == 5) kuaNumber = 8; // Female 5 -> 8
      }
    }

    final destinyGroup = [1, 3, 4, 9].contains(kuaNumber) 
        ? PersonalDestinyGroup.dongTu 
        : PersonalDestinyGroup.tayTu;

    return PersonalInfo(
      birthYear: birthYear,
      isMale: isMale,
      kuaNumber: kuaNumber,
      destinyGroup: destinyGroup,
    );
  }

  @override
  List<Object?> get props => [birthYear, isMale, kuaNumber, destinyGroup];
}

class FengShuiDirectionResult extends Equatable {
  final BaGuaDirection direction;
  final FengShuiDirectionType type;
  final String name;
  final String description;
  final bool isGood;
  final int priority; // 1-8, 1 is best

  const FengShuiDirectionResult({
    required this.direction,
    required this.type,
    required this.name,
    required this.description,
    required this.isGood,
    required this.priority,
  });

  @override
  List<Object?> get props => [direction, type, name, description, isGood, priority];
}

class FengShuiResult extends Equatable {
  final PersonalInfo personalInfo;
  final List<FengShuiDirectionResult> directions;

  const FengShuiResult({
    required this.personalInfo,
    required this.directions,
  });

  List<FengShuiDirectionResult> get goodDirections => 
      directions.where((d) => d.isGood).toList()..sort((a, b) => a.priority.compareTo(b.priority));
      
  List<FengShuiDirectionResult> get badDirections => 
      directions.where((d) => !d.isGood).toList()..sort((a, b) => a.priority.compareTo(b.priority));

  FengShuiDirectionResult? getDirectionType(BaGuaDirection direction) =>
      directions.firstWhere((d) => d.direction == direction);

  @override
  List<Object?> get props => [personalInfo, directions];
}