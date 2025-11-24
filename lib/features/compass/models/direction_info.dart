import 'package:equatable/equatable.dart';

enum CompassDirection {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
}

enum BaGuaDirection {
  kham, // Khảm - Bắc
  can, // Cấn - Đông Bắc
  chan, // Chấn - Đông
  ton, // Tốn - Đông Nam
  ly, // Ly - Nam
  khon, // Khôn - Tây Nam
  doai, // Đoài - Tây
  kien, // Càn - Tây Bắc
}

class DirectionInfo extends Equatable {
  final CompassDirection compassDirection;
  final BaGuaDirection baGuaDirection;
  final String vietnameseName;
  final String chineseName;
  final double startDegree;
  final double endDegree;
  final List<String> mountains; // 24 sơn

  const DirectionInfo({
    required this.compassDirection,
    required this.baGuaDirection,
    required this.vietnameseName,
    required this.chineseName,
    required this.startDegree,
    required this.endDegree,
    required this.mountains,
  });

  static List<DirectionInfo> get all => [
        const DirectionInfo(
          compassDirection: CompassDirection.north,
          baGuaDirection: BaGuaDirection.kham,
          vietnameseName: 'Bắc',
          chineseName: 'Khảm',
          startDegree: 337.5,
          endDegree: 22.5,
          mountains: ['Nhâm', 'Tý', 'Quý'],
        ),
        const DirectionInfo(
          compassDirection: CompassDirection.northEast,
          baGuaDirection: BaGuaDirection.can,
          vietnameseName: 'Đông Bắc',
          chineseName: 'Cấn',
          startDegree: 22.5,
          endDegree: 67.5,
          mountains: ['Sửu', 'Cấn', 'Dần'],
        ),
        const DirectionInfo(
          compassDirection: CompassDirection.east,
          baGuaDirection: BaGuaDirection.chan,
          vietnameseName: 'Đông',
          chineseName: 'Chấn',
          startDegree: 67.5,
          endDegree: 112.5,
          mountains: ['Giáp', 'Mão', 'Ất'],
        ),
        const DirectionInfo(
          compassDirection: CompassDirection.southEast,
          baGuaDirection: BaGuaDirection.ton,
          vietnameseName: 'Đông Nam',
          chineseName: 'Tốn',
          startDegree: 112.5,
          endDegree: 157.5,
          mountains: ['Thìn', 'Tốn', 'Tỵ'],
        ),
        const DirectionInfo(
          compassDirection: CompassDirection.south,
          baGuaDirection: BaGuaDirection.ly,
          vietnameseName: 'Nam',
          chineseName: 'Ly',
          startDegree: 157.5,
          endDegree: 202.5,
          mountains: ['Bính', 'Ngọ', 'Đinh'],
        ),
        const DirectionInfo(
          compassDirection: CompassDirection.southWest,
          baGuaDirection: BaGuaDirection.khon,
          vietnameseName: 'Tây Nam',
          chineseName: 'Khôn',
          startDegree: 202.5,
          endDegree: 247.5,
          mountains: ['Mùi', 'Khôn', 'Thân'],
        ),
        const DirectionInfo(
          compassDirection: CompassDirection.west,
          baGuaDirection: BaGuaDirection.doai,
          vietnameseName: 'Tây',
          chineseName: 'Đoài',
          startDegree: 247.5,
          endDegree: 292.5,
          mountains: ['Canh', 'Dậu', 'Tân'],
        ),
        const DirectionInfo(
          compassDirection: CompassDirection.northWest,
          baGuaDirection: BaGuaDirection.kien,
          vietnameseName: 'Tây Bắc',
          chineseName: 'Càn',
          startDegree: 292.5,
          endDegree: 337.5,
          mountains: ['Tuất', 'Càn', 'Hợi'],
        ),
      ];

  static DirectionInfo? getByHeading(double heading) {
    final normalizedHeading = heading < 0 ? heading + 360 : heading % 360;

    for (final direction in all) {
      if (direction.startDegree > direction.endDegree) {
        // Handle wrap-around case (North: 337.5-360, 0-22.5)
        if (normalizedHeading >= direction.startDegree ||
            normalizedHeading <= direction.endDegree) {
          return direction;
        }
      } else {
        // Normal case
        if (normalizedHeading >= direction.startDegree &&
            normalizedHeading <= direction.endDegree) {
          return direction;
        }
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
        compassDirection,
        baGuaDirection,
        vietnameseName,
        chineseName,
        startDegree,
        endDegree,
        mountains,
      ];
}
