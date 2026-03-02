// read_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_read/flutter_read.dart';
import 'menu.dart';


/// 将 BookSentence 转为完整字符串
String _sentenceToString(BookSentence sentence) {
  return sentence.words.map((word) => word.char).join('');
}

/// 去除字符串开头的空白字符（包括中文全角空格 \u3000）
// 👇 新增：预编译正则 + 辅助函数
final _leadingWhitespaceRegex = RegExp(r'^[\s\u3000]+');

String _trimLeadingWhitespace(String text) {
  return text.replaceFirst(_leadingWhitespaceRegex, '');
}

class ReadScreen extends StatefulWidget {
  final String bookAssetPath;

  const ReadScreen({super.key, required this.bookAssetPath});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  late final ReadController bookController;
  PersistentBottomSheetController? _menuController;
  StreamSubscription<BookProgress>? _progressSubscription;
  int _lastLoggedChapter = -1;

  // ignore: constant_identifier_names
  static const String _TAG = '_ReadScreenState';

  @override
  void initState() {
    super.initState();
    bookController = ReadController.create(
      loadingWidget: const Center(child: CircularProgressIndicator()),
      enableVerticalDrag: true,
      enableTapPage: true,
    );
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final data = await rootBundle.load(widget.bookAssetPath);
      final bookTitle = widget.bookAssetPath.split('/').last.replaceAll('.txt', '');
      final source = ByteDataSource(data, bookTitle, isSplit: true);

      await bookController.startReadBook(source);

      _progressSubscription = bookController.onPageIndexChanged.listen((progress) {
        if (!mounted) return;
        if (progress.chapterIndex == _lastLoggedChapter) return;
        _lastLoggedChapter = progress.chapterIndex;
        _logChapterSwitch(progress.chapterIndex);
      });
    } catch (e) {
      log.w("Failed to load book: $e", tag: _TAG);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("加载书籍失败: $e")),
      );
    }
  }

  void _logChapterSwitch(int chapterIndex) {
    try {
      final sentences = bookController.getSentenceFromIndex(chapterIndex);
      String title = '第${chapterIndex + 1}章';
      String preview = '';

      if (sentences != null && sentences.isNotEmpty) {
        final firstSentenceText = _sentenceToString(sentences[0]);

        // 启发式：如果第一句很短且包含章节关键词，视为标题
        if (firstSentenceText.length <= 30 &&
            RegExp(r'(第.*[章卷节]|引子|序章|尾声|Epilogue|Prologue)',
                caseSensitive: false).hasMatch(firstSentenceText)) {
          title = firstSentenceText.trim();
          // 预览用第二句（如果存在）
          if (sentences.length > 1) {
            final secondText = _trimLeadingWhitespace(_sentenceToString(sentences[1]));
            preview = secondText.substring(0, math.min(secondText.length, 20));
          } else {
            // 回退到第一句（清理后）
            final cleanedFirst = _trimLeadingWhitespace(firstSentenceText);
            preview = cleanedFirst.substring(0, math.min(cleanedFirst.length, 20));
          }
        } else {
          // 第一句不是标题，则整章无显式标题
          final cleanedFirst = _trimLeadingWhitespace(firstSentenceText);
          preview = cleanedFirst.substring(0, math.min(cleanedFirst.length, 20));
        }
      }

      final time = DateTime.now().toIso8601String();
      final sep = '-' * 120;
      log.i(sep, tag: _TAG);
      // 并使用清理后的 preview
      log.i('Time: $time | Title: $title | Preview: "$preview..."', tag: _TAG);
      log.i(sep, tag: _TAG);
    } catch (e) {
      log.w('Error logging chapter: $e', tag: _TAG);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8DC),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext scaffoldContext) {
            return ReadView(
              readController: bookController,
              onMenu: () {
                if (_menuController == null) {
                  _menuController = showBottomSheet(
                    context: scaffoldContext,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    builder: (context) => BookMenu(bookController: bookController),
                  )..closed.then((_) => _menuController = null);
                } else {
                  _menuController?.close();
                }
              },
              onScroll: () {
                _menuController?.close();
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}