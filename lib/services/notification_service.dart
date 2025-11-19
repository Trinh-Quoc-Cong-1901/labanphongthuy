import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:get/get.dart';
import '../models/notification_models.dart';

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('🔔 NotificationService initialized');
    }
    init();
  }

  Future<NotificationService> init() async {
    try {
      tz_data.initializeTimeZones();
      await _requestPermissions();
      await _initializeLocalNotifications();
      await _checkInitialNotification();
      return this;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('🔔 Error initializing Notification Service: $e');
        print(stackTrace);
      }
      return this;
    }
  }

  // Request permissions
  Future<void> _requestPermissions() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      if (kDebugMode) print('🔔 Permission request error: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      if (kDebugMode) print('🔔 Local notifications initialized successfully');
    } catch (e) {
      if (kDebugMode) print('🔔 Local notification init error: $e');
      _initialized = false;
    }
  }

  // Check for initial notification
  Future<void> _checkInitialNotification() async {
    try {
      final details = await _notifications.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true) {
        final payload = details?.notificationResponse?.payload;
        if (payload != null) {
          _handleNotificationPayload(payload);
        }
      }
    } catch (e) {
      if (kDebugMode) print('🔔 Check initial notification error: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      _handleNotificationPayload(response.payload!);
    }
  }

  // Handle notification payload
  static void _handleNotificationPayload(String payload) {
    try {
      final data = jsonDecode(payload);
      final route = data['route'];

      if (route != null && Get.context != null) {
        // Navigate to specific screen
        Get.toNamed(route, arguments: data);
      }
    } catch (e) {
      if (kDebugMode) print('🔔 Payload handling error: $e');
    }
  }

  // Schedule event notification with lich-am style intelligence
  Future<void> scheduleEventNotification(NotificationEvent event) async {
    await cancelEventNotification(event.id);

    if (!event.isNotify) return;

    await _scheduleEventNotificationInternal(event);
  }

  // Internal method to schedule event notifications
  Future<void> _scheduleEventNotificationInternal(
      NotificationEvent event) async {
    try {
      // Handle simple notification config
      if (event.simpleNotificationConfig != null) {
        await _scheduleSimpleNotification(
            event, event.simpleNotificationConfig!);
      }

      // Handle custom reminders
      if (event.customReminders != null && event.customReminders!.isNotEmpty) {
        for (int i = 0; i < event.customReminders!.length; i++) {
          await _scheduleCustomReminder(event, event.customReminders![i], i);
        }
      }
    } catch (e) {
      if (kDebugMode) print('🔔 Schedule error: $e');
    }
  }

  // Schedule simple notification
  Future<void> _scheduleSimpleNotification(
      NotificationEvent event, SimpleNotificationConfig config) async {
    if (config.notifyOnDay) {
      // Parse notification time
      final timeParts = config.notifyTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final scheduleTime = _combineDateTime(event.dateTime, hour, minute);

      if (scheduleTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: event.id.hashCode,
          title: event.title,
          body: event.content,
          scheduledTime: scheduleTime,
          payload: event.payload ?? '',
        );
      }
    }

    // Schedule notifications for minutes before
    for (int minutesBefore in config.notifyMinutesBefore) {
      if (minutesBefore > 0) {
        final scheduleTime =
            event.dateTime.subtract(Duration(minutes: minutesBefore));

        if (scheduleTime.isAfter(DateTime.now())) {
          final prefix = _getTimePrefix(minutesBefore);
          await _scheduleNotification(
            id: '${event.id}_$minutesBefore'.hashCode,
            title: '🔔 ${event.title}',
            body: '$prefix ${event.content}',
            scheduledTime: scheduleTime,
            payload: event.payload ?? '',
          );
        }
      }
    }
  }

  // Schedule custom reminder
  Future<void> _scheduleCustomReminder(
      NotificationEvent event, CustomReminderConfig config, int index) async {
    DateTime? scheduleTime;

    if (config.type == CustomReminderType.countdown) {
      final totalMinutes =
          (config.countdownHours ?? 0) * 60 + (config.countdownMinutes ?? 0);
      scheduleTime = event.dateTime.subtract(Duration(minutes: totalMinutes));
    } else if (config.type == CustomReminderType.specificDate &&
        config.specificDateTime != null) {
      scheduleTime = config.specificDateTime!;
    }

    if (scheduleTime != null && scheduleTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: '${event.id}_custom_$index'.hashCode,
        title: '🔔 ${event.title}',
        body: event.content,
        scheduledTime: scheduleTime,
        payload: event.payload ?? '',
      );
    }
  }

  // Schedule daily feng shui notifications
  Future<void> scheduleDailyNotifications() async {
    if (kDebugMode) print('🔔 Starting scheduleDailyNotifications');

    final prefs = await SharedPreferences.getInstance();
    final kuaNumber = prefs.getInt('user_kua_number');

    // Cancel all previous notifications
    try {
      await _notifications.cancelAll();
      if (kDebugMode) print('🔔 Cancelled all previous notifications');
    } catch (e) {
      if (kDebugMode) print('🔔 Error cancelling notifications: $e');
    }

    // Schedule morning notification (7:30)
    await _scheduleMorningNotification(kuaNumber);

    // Schedule weekly notification (Sunday 10:00)
    await _scheduleWeeklyNotification();

    if (kDebugMode) print('🔔 All notifications scheduled successfully');
  }

  // Schedule morning notification
  Future<void> _scheduleMorningNotification(int? kuaNumber) async {
    final title = "🌅 Chào buổi sáng!";
    final body = _getMorningMessage(kuaNumber);

    debugPrint('🔔 [Morning] Scheduling morning notification at 7:30');
    debugPrint('🔔 [Morning] Title: $title');
    debugPrint('🔔 [Morning] Body: $body');

    await _scheduleRepeatingNotification(
      id: 1,
      title: title,
      body: body,
      hour: 7,
      minute: 30,
      payload: 'morning_compass',
    );
  }

  // Schedule weekly notification
  Future<void> _scheduleWeeklyNotification() async {
    final title = "📚 Kiến thức phong thủy tuần";
    final body = _getWeeklyWisdom();

    await _scheduleWeeklyRepeating(
      id: 3,
      title: title,
      body: body,
      weekday: DateTime.sunday,
      hour: 10,
      minute: 0,
      payload: 'weekly_wisdom',
    );
  }

  // Core notification scheduling method
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    try {
      final tzScheduledTime = _convertToTZDateTime(scheduledTime);
      if (kDebugMode)
        print('🔔 Scheduling notification ID: $id at $tzScheduledTime');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'feng_shui_compass',
            'La Bàn Phong Thủy',
            channelDescription: 'Thông báo và lời khuyên phong thủy',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      if (kDebugMode) print('🔔 Successfully scheduled notification ID: $id');
    } catch (e) {
      if (kDebugMode) print('🔔 ERROR scheduling notification ID: $id - $e');
    }
  }

  // Schedule repeating notification (for daily feng shui tips)
  Future<void> _scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {
    try {
      final scheduledTime = _nextInstanceOfTime(hour, minute);
      if (kDebugMode) print('🔔 Scheduling repeating notification ID: $id');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_feng_shui',
            'Phong Thủy Hàng Ngày',
            channelDescription: 'Thông báo và lời khuyên phong thủy hàng ngày',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
    } catch (e) {
      if (kDebugMode) print('🔔 ERROR scheduling repeating notification: $e');
    }
  }

  // Schedule weekly repeating notification
  Future<void> _scheduleWeeklyRepeating({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required String payload,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfWeekday(weekday, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_feng_shui',
            'Phong Thủy Tuần',
            channelDescription: 'Kiến thức phong thủy chuyên sâu hàng tuần',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      debugPrint('🔔 [Weekly] Successfully scheduled weekly notification');
    } catch (e) {
      debugPrint('🔔 [Weekly] ERROR scheduling weekly notification: $e');
      // Weekly notifications not critical, can skip
    }
  }

  // Convert DateTime to TZDateTime
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    return tz.TZDateTime.from(dateTime, location);
  }

  // Combine date with time
  DateTime _combineDateTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Get time prefix for notifications
  String _getTimePrefix(int minutesBefore) {
    if (minutesBefore < 60) {
      return 'Trong $minutesBefore phút nữa:';
    } else if (minutesBefore < 1440) {
      final hours = minutesBefore ~/ 60;
      return 'Trong $hours giờ nữa:';
    } else {
      final days = minutesBefore ~/ 1440;
      return 'Trong $days ngày nữa:';
    }
  }

  // Calculate next instance of time for daily repeating notifications
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    final now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Calculate next instance of weekday for weekly notifications
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    final now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  // Cancel event notification
  Future<void> cancelEventNotification(String eventId) async {
    try {
      await _notifications.cancel(eventId.hashCode);
      if (kDebugMode) print('🔔 Cancelled notification for event: $eventId');
    } catch (e) {
      if (kDebugMode) print('🔔 Error cancelling notification: $e');
    }
  }

  // Get morning message based on Kua number
  String _getMorningMessage(int? kuaNumber) {
    if (kuaNumber == null) {
      return "Hãy kiểm tra hướng tốt cho ngày hôm nay! 🧭";
    }

    final messages = {
      1: "Hướng Bắc đang rất tốt cho bạn hôm nay! 🧭 ❄️",
      2: "Hướng Tây Nam mang lại may mắn cho Kua 2! ✨ 🏔️",
      3: "Năng lượng phía Đông rất mạnh mẽ cho bạn! 🌱 ⚡",
      4: "Hướng Đông Nam là lựa chọn tuyệt vời! 🍃 💨",
      6: "Phía Tây Bắc sẽ hỗ trợ bạn trong ngày hôm nay! ⛰️ 💎",
      7: "Hướng Tây mang đến cơ hội mới cho bạn! 🌅 ⚔️",
      8: "Tây Bắc là hướng thịnh vượng của Kua 8! 💎 🏔️",
      9: "Phía Nam - hướng danh tiếng đang rất thuận! 🔥 ☀️"
    };

    return messages[kuaNumber] ?? "Hãy kiểm tra hướng tốt cho ngày hôm nay! 🧭";
  }

  // Get weekly feng shui wisdom
  String _getWeeklyWisdom() {
    final wisdom = [
      "🔍 5 yếu tố: Kim, Mộc, Thủy, Hỏa, Thổ tác động đến cuộc sống",
      "📐 Tỷ lệ vàng trong thiết kế tạo hài hòa năng lượng",
      "🧭 La bàn Luo Pan có 384 hướng chi tiết để phân tích",
      "🏠 9 cung trong nhà tương ứng với 9 khía cạnh cuộc sống",
      "⭐ Sao Bắc Đẩu chi phối vận mệnh theo từng năm",
      "🌊 Nước chảy khúc khiu mang lại tài lộc tốt hơn",
      "🪴 Cây lá nhọn nên tránh trong nhà, chọn lá tròn",
    ];

    final random = Random();
    return wisdom[random.nextInt(wisdom.length)];
  }

  // Show instant notification
  Future<void> showInstantNotification(String title, String body,
      {String? payload}) async {
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'instant',
            'Thông Báo Tức Thì',
            channelDescription: 'Thông báo quan trọng ngay lập tức',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) print('🔔 Error showing instant notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      if (kDebugMode) print('🔔 Cancelled all notifications');
    } catch (e) {
      if (kDebugMode) print('🔔 Error cancelling all notifications: $e');
    }
  }

  // Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      if (kDebugMode) print('🔔 Cancelled notification ID: $id');
    } catch (e) {
      if (kDebugMode) print('🔔 Error cancelling notification ID $id: $e');
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      // For Android
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? granted = await androidPlugin.areNotificationsEnabled();
        return granted ?? false;
      }

      // For iOS
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final result = await iosPlugin.checkPermissions();
        return result?.isEnabled == true;
      }

      return true; // Default for web/desktop
    } catch (e) {
      if (kDebugMode) print('🔔 Error checking notification permissions: $e');
      return false;
    }
  }
}
