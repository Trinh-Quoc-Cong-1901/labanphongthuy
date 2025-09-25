import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/notification_models.dart';

class NotificationController extends GetxController {
  // State variables
  final RxBool notificationsEnabled = true.obs;
  final RxBool hasPermission = false.obs;
  final RxList<NotificationEvent> events = <NotificationEvent>[].obs;
  static bool _notificationsScheduled = false;

  // Get notification service instance
  NotificationService get notificationService => Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    _loadNotificationSettings();
    _checkAndRequestPermissions();
  }

  // Load cài đặt notification từ SharedPreferences
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
  }

  // Check and request permissions
  Future<void> _checkAndRequestPermissions() async {
    final enabled = await notificationService.areNotificationsEnabled();
    hasPermission.value = enabled;

    if (enabled && notificationsEnabled.value) {
      await _scheduleDefaultNotifications();
    }
  }

  // Toggle notifications on/off
  Future<void> toggleNotifications(bool enabled) async {
    notificationsEnabled.value = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled && hasPermission.value) {
      _notificationsScheduled = false;
      await _scheduleDefaultNotifications();
    } else {
      _notificationsScheduled = false;
      await notificationService.cancelAllNotifications();
    }
  }

  // Schedule default feng shui notifications
  Future<void> _scheduleDefaultNotifications() async {
    if (_notificationsScheduled) {
      return;
    }
    _notificationsScheduled = true;
    await notificationService.scheduleDailyNotifications();
  }


  // Add notification event
  Future<void> addNotificationEvent(NotificationEvent event) async {
    events.add(event);
    if (event.isNotify) {
      await notificationService.scheduleEventNotification(event);
    }
  }

  // Remove notification event
  Future<void> removeNotificationEvent(String eventId) async {
    events.removeWhere((event) => event.id == eventId);
    await notificationService.cancelEventNotification(eventId);
  }

  // Update notification event
  Future<void> updateNotificationEvent(NotificationEvent event) async {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await notificationService.scheduleEventNotification(event);
    }
  }



  // Track compass usage and send achievement notifications
  Future<void> trackCompassUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final usageCount = prefs.getInt('compass_usage_count') ?? 0;
    final newCount = usageCount + 1;
    await prefs.setInt('compass_usage_count', newCount);

    // Check for achievements and send notifications
    await _checkAchievements(newCount);
  }

  // Check achievements and send notifications
  Future<void> _checkAchievements(int usageCount) async {
    String? achievement;

    switch (usageCount) {
      case 1:
        achievement = "🎉 Lần đầu sử dụng la bàn! Chào mừng bạn đến với phong thủy";
        break;
      case 7:
        achievement = "🔥 Sử dụng la bàn 7 lần! Bạn đang làm rất tốt";
        break;
      case 30:
        achievement = "⭐ Chuyên gia phong thủy! 30 lần sử dụng la bàn";
        break;
      case 100:
        achievement = "🏆 Bậc thầy la bàn! 100 lần sử dụng - Impressive!";
        break;
    }

    if (achievement != null && hasPermission.value && notificationsEnabled.value) {
      await notificationService.showInstantNotification(
        "🎯 Thành tích mới!",
        achievement,
      );
    }
  }

  // Send direction reminder based on current time
  Future<void> sendDirectionReminder() async {
    if (!notificationsEnabled.value || !hasPermission.value) return;

    final prefs = await SharedPreferences.getInstance();
    final kuaNumber = prefs.getInt('user_kua_number');

    if (kuaNumber != null) {
      final direction = _getBestDirectionForTime(kuaNumber);
      await notificationService.showInstantNotification(
        "🧭 Hướng tốt cho bạn",
        "Kua $kuaNumber: $direction là hướng thuận lợi lúc này! ✨",
      );
    }
  }

  // Get best direction based on time of day and Kua number
  String _getBestDirectionForTime(int kuaNumber) {
    final hour = DateTime.now().hour;

    // Simple logic based on hour and Kua number
    final directions = {
      1: ["Bắc", "Đông", "Đông Nam", "Nam"],
      2: ["Tây Nam", "Tây Bắc", "Tây", "Đông Bắc"],
      3: ["Đông", "Nam", "Bắc", "Đông Nam"],
      4: ["Đông Nam", "Đông", "Nam", "Bắc"],
      6: ["Tây Bắc", "Tây", "Đông Bắc", "Tây Nam"],
      7: ["Tây", "Đông Bắc", "Tây Bắc", "Tây Nam"],
      8: ["Đông Bắc", "Tây Nam", "Tây", "Tây Bắc"],
      9: ["Nam", "Đông", "Đông Nam", "Bắc"],
    };

    final kuaDirections = directions[kuaNumber] ?? ["Bắc"];
    final timeIndex = (hour ~/ 6) % kuaDirections.length;

    return kuaDirections[timeIndex];
  }

  // Check if should show daily reminder
  Future<bool> shouldShowDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReminderDate = prefs.getString('last_reminder_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastReminderDate != today) {
      await prefs.setString('last_reminder_date', today);
      return true;
    }

    return false;
  }
}