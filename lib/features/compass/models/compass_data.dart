import 'package:equatable/equatable.dart';

class CompassData extends Equatable {
  final double heading;
  final double magneticDeclination;
  final bool isCalibrated;
  final DateTime timestamp;

  const CompassData({
    required this.heading,
    this.magneticDeclination = 0.0,
    this.isCalibrated = true,
    required this.timestamp,
  });

  factory CompassData.initial() => CompassData(
        heading: 0.0,
        magneticDeclination: 0.0,
        isCalibrated: false,
        timestamp: DateTime.now(),
      );

  CompassData copyWith({
    double? heading,
    double? magneticDeclination,
    bool? isCalibrated,
    DateTime? timestamp,
  }) {
    return CompassData(
      heading: heading ?? this.heading,
      magneticDeclination: magneticDeclination ?? this.magneticDeclination,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  double get trueHeading => (heading + magneticDeclination) % 360;

  double get normalizedHeading => heading < 0 ? heading + 360 : heading;

  @override
  List<Object?> get props =>
      [heading, magneticDeclination, isCalibrated, timestamp];
}
