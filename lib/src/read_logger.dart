// lib/utils/app_logger.dart
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// 全局结构化日志实例
final AppLogger log = AppLogger._();

class AppLogger {
  AppLogger._() {
    _init();
  }


  void _init() {
    Logger.root.level = Level.ALL;
    // 不再监听 root，改由我们手动控制输出
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

  String? _extractCallerInfo(StackTrace? stackTrace) {
    if (stackTrace == null) return null;
    final lines = stackTrace.toString().split('\n');
    // 从第 0 行开始找业务代码（跳过 logging 内部调用）
    for (int i = 0; i < lines.length && i < 8; i++) {
      // 跳过包内部、框架、或未知行
      if (lines[i].contains('package:logging/') ||
          lines[i].contains('dart:async/') ||
          lines[i].contains('<asynchronous suspension>') ||
          !lines[i].contains('.dart:')) {
        continue;
      }
      final match = RegExp(r'([^\/\\]+\.dart):(\d+)').firstMatch(lines[i]);
      if (match != null) {
        return '${match.group(1)}:${match.group(2)}';
      }
    }
    return null;
  }

  // ====== Public API（支持显式 tag，不伪造 StackTrace）======
  void d(String msg, {String? tag}) => _logDirect(Level.FINE, msg, tag: tag);
  void i(String msg, {String? tag}) => _logDirect(Level.INFO, msg, tag: tag);
  void w(String msg, {String? tag}) => _logDirect(Level.WARNING, msg, tag: tag);
  void e(String msg, {Object? error, String? tag}) => _logDirect(Level.SEVERE, msg, error: error, tag: tag);

  void _logDirect(Level level, String message, {Object? error, String? tag}) {
    // Release 模式只输出 WARNING 及以上
    if (!kDebugMode && level != Level.WARNING && level != Level.SEVERE) {
      return;
    }

    final time = _formatTime(DateTime.now());
    final levelTag = _getLevelTag(level);
    final caller = tag ?? _extractCallerInfo(StackTrace.current) ?? 'unknown';
    final logLine = '[$time] $levelTag $caller - $message';

    debugPrint(logLine);

    if (error != null) {
      debugPrint('  💥 Error: $error');
      // 仅在有 error 且 debug 模式下打印堆栈
      if (kDebugMode) {
        final stackLines = StackTrace.current.toString().split('\n').take(3);
        for (final line in stackLines) {
          if (line.trim().isNotEmpty) {
            debugPrint('  📜 $line');
          }
        }
      }
    }
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