// lib/utils/app_logger.dart
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// 全局结构化日志实例
final AppLogger log = AppLogger._();

class AppLogger {
  AppLogger._() {
    _init();
  }

  late Logger _logger;

  void _init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // Release 模式只输出 WARNING 及以上
      if (!kDebugMode && record.level != Level.WARNING && record.level != Level.SEVERE) {
        return;
      }
      _printLog(record);
    });
    _logger = Logger('FlutterRead');
  }

  void _printLog(LogRecord record) {
    final time = _formatTime(record.time);
    final levelTag = _getLevelTag(record.level);
    final caller = _extractCallerInfo(record.stackTrace);
    final message = '[$time] $levelTag $caller - ${record.message}';

    debugPrint(message);

    if (record.error != null) {
      debugPrint('  💥 Error: ${record.error}');
    }
    if (record.stackTrace != null && kDebugMode) {
      final stackLines = record.stackTrace.toString().split('\n').take(3);
      for (final line in stackLines) {
        debugPrint('  📜 $line');
      }
    }
  }

  String _formatTime(DateTime time) {
    final hms = time.toIso8601String().split('T').last.split('.').first;
    final ms = time.millisecond.toString().padLeft(3, '0');
    return '$hms.$ms';
  }

  String _getLevelTag(Level level) {
    if (level == Level.SEVERE) return 'ERROR';
    if (level == Level.WARNING) return 'WARN ';
    if (level == Level.INFO) return 'INFO ';
    return 'DEBUG';
  }

  String _extractCallerInfo(StackTrace? stackTrace) {
    if (stackTrace == null) return 'unknown';
    final lines = stackTrace.toString().split('\n');
    for (int i = 2; i < lines.length && i < 6; i++) {
      final match = RegExp(r'([^\/\\]+\.dart):(\d+)').firstMatch(lines[i]);
      if (match != null) {
        return '${match.group(1)}:${match.group(2)}';
      }
    }
    return 'unknown';
  }

  // ====== Public API ======
  void d(String msg) => _logger.fine(msg);
  void i(String msg) => _logger.info(msg);
  void w(String msg) => _logger.warning(msg);
  void e(String msg, {Object? error, StackTrace? stackTrace}) {
    _logger.severe(msg, error, stackTrace ?? StackTrace.current);
  }
}

/// 章节日志项（替代 record）
class ChapterLogItem {
  final int index;
  final String title;
  final String message;
  final String? details;

  ChapterLogItem({
    required this.index,
    required this.title,
    required this.message,
    this.details,
  });
}

/// 小说阅读器专用：美观的章节日志（无 record，兼容 Dart 2.17+）
class ChapterLogger {
  /// 打印带分隔框的章节日志
  static void logChapters({
    required List<ChapterLogItem> chapters,
    String? boxTitle,
  }) {
    if (!kDebugMode) return;

    final sep = '-' * 64;
    final lines = <String>[];

    lines.add(sep);
    if (boxTitle != null) {
      lines.add(boxTitle);
      lines.add(sep);
    }

    for (final c in chapters) {
      final detailPart = c.details != null ? ' (${c.details})' : '';
      lines.add('[第${c.index}章：${c.title}] ${c.message}$detailPart');
      lines.add(sep);
    }

    for (final line in lines) {
      debugPrint(line);
    }
  }

  /// 快捷方法：仅打印章节目录
  static void logChapterList(List<String> titles) {
    if (!kDebugMode) return;

    final chapters = <ChapterLogItem>[];
    for (int i = 0; i < titles.length; i++) {
      chapters.add(
        ChapterLogItem(
          index: i + 1,
          title: titles[i],
          message: '',
          details: null,
        ),
      );
    }

    logChapters(
      chapters: chapters,
      boxTitle: '【小说目录】共 ${titles.length} 章',
    );
  }
}