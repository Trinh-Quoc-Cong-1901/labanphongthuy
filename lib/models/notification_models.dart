class SimpleNotificationConfig {
  final bool notifyOnDay;
  final List<int> notifyMinutesBefore; // Minutes before event
  final String notifyTime; // Default notification time like "07:30"

  const SimpleNotificationConfig({
    this.notifyOnDay = true,
    this.notifyMinutesBefore = const [0], // Default: notify at event time
    this.notifyTime = "07:30",
  });

  factory SimpleNotificationConfig.fromJson(Map<String, dynamic> json) {
    return SimpleNotificationConfig(
      notifyOnDay: json['notifyOnDay'] ?? true,
      notifyMinutesBefore: List<int>.from(json['notifyMinutesBefore'] ?? [0]),
      notifyTime: json['notifyTime'] ?? "07:30",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifyOnDay': notifyOnDay,
      'notifyMinutesBefore': notifyMinutesBefore,
      'notifyTime': notifyTime,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleNotificationConfig &&
          runtimeType == other.runtimeType &&
          notifyOnDay == other.notifyOnDay &&
          notifyTime == other.notifyTime;

  @override
  int get hashCode => notifyOnDay.hashCode ^ notifyTime.hashCode;
}

enum CustomReminderType { countdown, specificDate }

class CustomReminderConfig {
  final CustomReminderType type;
  final int? countdownHours;
  final int? countdownMinutes;
  final DateTime? specificDateTime;

  const CustomReminderConfig({
    required this.type,
    this.countdownHours,
    this.countdownMinutes,
    this.specificDateTime,
  });

  factory CustomReminderConfig.fromJson(Map<String, dynamic> json) {
    return CustomReminderConfig(
      type: CustomReminderType.values[json['type'] ?? 0],
      countdownHours: json['countdownHours'],
      countdownMinutes: json['countdownMinutes'],
      specificDateTime: json['specificDateTime'] != null
          ? DateTime.parse(json['specificDateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'countdownHours': countdownHours,
      'countdownMinutes': countdownMinutes,
      'specificDateTime': specificDateTime?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomReminderConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          countdownHours == other.countdownHours &&
          countdownMinutes == other.countdownMinutes &&
          specificDateTime == other.specificDateTime;

  @override
  int get hashCode =>
      type.hashCode ^
      countdownHours.hashCode ^
      countdownMinutes.hashCode ^
      specificDateTime.hashCode;
}

class NotificationEvent {
  final String id;
  final String title;
  final String content;
  final DateTime dateTime;
  final bool isNotify;
  final SimpleNotificationConfig? simpleNotificationConfig;
  final List<CustomReminderConfig>? customReminders;
  final String? payload;

  const NotificationEvent({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.isNotify = true,
    this.simpleNotificationConfig,
    this.customReminders,
    this.payload,
  });

  factory NotificationEvent.fromJson(Map<String, dynamic> json) {
    return NotificationEvent(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      dateTime: DateTime.parse(json['dateTime']),
      isNotify: json['isNotify'] ?? true,
      simpleNotificationConfig: json['simpleNotificationConfig'] != null
          ? SimpleNotificationConfig.fromJson(json['simpleNotificationConfig'])
          : null,
      customReminders: json['customReminders'] != null
          ? List<CustomReminderConfig>.from(json['customReminders']
              .map((x) => CustomReminderConfig.fromJson(x)))
          : null,
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateTime': dateTime.toIso8601String(),
      'isNotify': isNotify,
      'simpleNotificationConfig': simpleNotificationConfig?.toJson(),
      'customReminders': customReminders?.map((x) => x.toJson()).toList(),
      'payload': payload,
    };
  }

  NotificationEvent copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? dateTime,
    bool? isNotify,
    SimpleNotificationConfig? simpleNotificationConfig,
    List<CustomReminderConfig>? customReminders,
    String? payload,
  }) {
    return NotificationEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateTime: dateTime ?? this.dateTime,
      isNotify: isNotify ?? this.isNotify,
      simpleNotificationConfig:
          simpleNotificationConfig ?? this.simpleNotificationConfig,
      customReminders: customReminders ?? this.customReminders,
      payload: payload ?? this.payload,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
