class LoggerUtils {
  static void debug(String message) {
    print('[DEBUG] $message');
  }

  static void info(String message) {
    print('[INFO] $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) print('[ERROR] $error');
    if (stackTrace != null) print('[ERROR] $stackTrace');
  }

  static void warning(String message) {
    print('[WARNING] $message');
  }
}
