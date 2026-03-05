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
    // 可选：初始化 logging 包（但本类不依赖它输出）
    Logger.root.level = Level.ALL;
    // 注意：我们不添加任何监听器，避免干扰
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
    for (int i = 0; i < lines.length && i < 8; i++) {
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

  // ====== Public API ======
  void d(String msg, {String? tag}) => _logDirect(Level.FINE, msg, tag: tag);
  void i(String msg, {String? tag}) => _logDirect(Level.INFO, msg, tag: tag);
  void w(String msg, {String? tag}) => _logDirect(Level.WARNING, msg, tag: tag);
  void e(String msg, {Object? error, String? tag}) => _logDirect(Level.SEVERE, msg, error: error, tag: tag);

  void _logDirect(Level level, String message, {Object? error, String? tag}) {
    // ⚠️ 关键修复：不再使用 log.i(...) 打印分隔线，避免递归！
    final sep = '-' * 158;

    // Release 模式只输出 WARNING 及以上
    if (!kDebugMode && level != Level.WARNING && level != Level.SEVERE) {
      return;
    }

    // 直接使用 debugPrint 输出分隔线
    debugPrint(sep);

    final time = _formatTime(DateTime.now());
    final levelTag = _getLevelTag(level);
    final caller = tag ?? _extractCallerInfo(StackTrace.current) ?? 'unknown';
    final logLine = '[$time] $levelTag $caller - $message';

    debugPrint(logLine);

    if (error != null) {
      debugPrint('  💥 Error: $error');
      if (kDebugMode) {
        final stackLines = StackTrace.current.toString().split('\n').take(3);
        for (final line in stackLines) {
          if (line.trim().isNotEmpty) {
            debugPrint('  📜 $line');
          }
        }
      }
    }

    // 结尾分隔线也用 debugPrint
    debugPrint(sep);
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