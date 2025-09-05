import 'package:flutter_test/flutter_test.dart';
import 'package:la_ban_phong_thuy/features/compass/models/feng_shui_result.dart';

void main() {
  group('Compass Tests', () {
    test('PersonalInfo calculation should work correctly', () {
      // Test male born in 1990
      final male1990 = PersonalInfo.calculate(1990, true);
      expect(male1990.kuaNumber, isA<int>());
      expect(male1990.kuaNumber, greaterThan(0));
      expect(male1990.kuaNumber, lessThanOrEqualTo(9));
      
      // Test female born in 1990
      final female1990 = PersonalInfo.calculate(1990, false);
      expect(female1990.kuaNumber, isA<int>());
      expect(female1990.kuaNumber, greaterThan(0));
      expect(female1990.kuaNumber, lessThanOrEqualTo(9));
    });

    test('FengShuiDirectionType should have all 8 directions', () {
      expect(FengShuiDirectionType.values.length, equals(8));
    });
  });
}