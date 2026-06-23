/// 全局开关：控制调试信息是否暴露给 UI。
///
/// - release 模式：默认 false，错误提示走用户友好文案。
/// - debug 模式：默认 true，错误提示会附上 Dio 类型、状态码、URL、method 摘要，
///   便于在登录页/网络层排错。
class AppConfig {
  AppConfig._();

  /// 是否启用详细错误信息（仅用于 UI 展示，不影响日志）。
  static const bool verboseErrors = bool.fromEnvironment(
    'VERBOSE_ERRORS',
    defaultValue: true, // 仓库当前处于开发期，默认开启
  );

  /// 单条错误信息最多展示的字符数（防止 SnackBar/Banner 撑爆屏幕）。
  static const int maxErrorLength = 120;

  /// 把任意对象/异常压成一行可读字符串。
  static String summarize(Object? raw) {
    if (raw == null) return '未知错误';
    var text = raw.toString();
    if (text.length > maxErrorLength) {
      text = '${text.substring(0, maxErrorLength)}…';
    }
    return text;
  }
}
