/// Simple lunar date model
class LunarDate {
  final int year;
  final int month;
  final int day;
  final bool isLeap;

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    required this.isLeap,
  });

  @override
  String toString() {
    return 'LunarDate(year: $year, month: $month, day: $day, isLeap: $isLeap)';
  }
}

/// Simple lunar calendar service for La Bàn Phong Thủy app
/// This is a simplified implementation for context enrichment
class LunarService {
  // Cache for lunar date calculations
  static final Map<String, LunarDate> _lunarDateCache = {};

  /// Convert solar date to lunar date (simplified implementation)
  static LunarDate getSolarToLunar(DateTime date) {
    final localDate = date.toLocal();
    final key = '${localDate.year}-${localDate.month}-${localDate.day}';

    if (_lunarDateCache.containsKey(key)) {
      return _lunarDateCache[key]!;
    }

    // Simplified lunar calculation (for demo purposes)
    // In real app, you would use proper lunar calendar conversion
    final lunarDate = _simpleLunarConversion(localDate);

    // Cache the result
    _lunarDateCache[key] = lunarDate;

    // Limit cache size to prevent memory issues
    if (_lunarDateCache.length > 100) {
      _lunarDateCache.remove(_lunarDateCache.keys.first);
    }

    return lunarDate;
  }

  /// Simple lunar conversion (placeholder implementation)
  static LunarDate _simpleLunarConversion(DateTime solarDate) {
    // This is a very simplified conversion for demo
    // In real implementation, you would use proper lunar calendar algorithms
    final dayOffset = solarDate.difference(DateTime(2024, 1, 1)).inDays;
    final lunarDay = (dayOffset % 30) + 1;
    final lunarMonth = ((dayOffset ~/ 30) % 12) + 1;
    final lunarYear = solarDate.year;
    final isLeap = lunarMonth == 6; // Simplified leap month detection

    return LunarDate(
      year: lunarYear,
      month: lunarMonth,
      day: lunarDay,
      isLeap: isLeap,
    );
  }

  /// Get lunar date info as a simple map
  static Map<String, dynamic> getLunarDateInfo(DateTime date) {
    final lunar = getSolarToLunar(date);

    return {
      'day': lunar.day,
      'month': lunar.month,
      'year': lunar.year,
      'isLeap': lunar.isLeap,
      'dayString': _getDayString(lunar.day),
      'monthString': _getMonthString(lunar.month),
    };
  }

  /// Get day of week in Vietnamese
  static String getDayOfWeekVietnamese(int weekday) {
    switch (weekday) {
      case 1:
        return "Thứ Hai";
      case 2:
        return "Thứ Ba";
      case 3:
        return "Thứ Tư";
      case 4:
        return "Thứ Năm";
      case 5:
        return "Thứ Sáu";
      case 6:
        return "Thứ Bảy";
      case 7:
        return "Chủ Nhật";
      default:
        return "Không rõ";
    }
  }

  /// Get lunar day string representation
  static String _getDayString(int day) {
    if (day == 1) return 'Mùng 1';
    if (day <= 10) return 'Mùng $day';
    if (day <= 19) return 'Ngày ${day - 10}0${day % 10}';
    if (day == 20) return 'Ngày 20';
    if (day <= 29) return 'Ngày ${day - 20}0${day % 10}';
    return 'Ngày 30';
  }

  /// Get lunar month string representation
  static String _getMonthString(int month) {
    const months = [
      '', 'Giêng', 'Hai', 'Ba', 'Tư', 'Năm', 'Sáu',
      'Bảy', 'Tám', 'Chín', 'Mười', 'Mười một', 'Chạp'
    ];
    return month >= 1 && month <= 12 ? months[month] : 'Không rõ';
  }

  /// Get formatted lunar date string
  static String getFormattedLunarDate(DateTime date) {
    final lunarInfo = getLunarDateInfo(date);
    final dayStr = lunarInfo['dayString'] ?? 'Không rõ';
    final monthStr = lunarInfo['monthString'] ?? 'Không rõ';
    final year = lunarInfo['year'] ?? 2024;
    final isLeap = lunarInfo['isLeap'] ?? false;

    String result = '$dayStr tháng $monthStr năm $year';
    if (isLeap) {
      result += ' (tháng nhuận)';
    }

    return result;
  }

  /// Check if today is auspicious (simplified)
  static bool isLuckyDay(DateTime date) {
    final lunar = getSolarToLunar(date);
    final day = lunar.day;

    // Simple lucky day calculation (can be improved)
    // Lucky days: 1, 6, 8, 9, 15, 16, 18, 19, 23, 24, 28, 29
    final luckyDays = [1, 6, 8, 9, 15, 16, 18, 19, 23, 24, 28, 29];
    return luckyDays.contains(day);
  }

  /// Clear cache (for memory management)
  static void clearCache() {
    _lunarDateCache.clear();
  }

  /// Get cache size for debugging
  static int getCacheSize() {
    return _lunarDateCache.length;
  }
}