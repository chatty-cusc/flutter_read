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

/// 彻底清理字符串首尾空白（包括空格、\t、\n、\r、全角空格 \u3000）
String _cleanText(String text) {
  return text
      .replaceAll(RegExp(r'^[\s\u3000\n\r\t]+'), '')
      .replaceAll(RegExp(r'[\s\u3000\n\r\t]+$'), '');
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
        // 使用 getSourceFromIndex 获取章节标题
        final chapterTitle = bookController.getSourceFromIndex(progress.chapterIndex)?.getTitle() ?? '第${progress.chapterIndex + 1}章';
        _logChapterSwitch(progress.chapterIndex, chapterTitle);
      });
    } catch (e) {
      log.w("Failed to load book: $e", tag: _TAG);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("加载书籍失败: $e")),
      );
    }
  }

  void _logChapterSwitch(int chapterIndex, String chapterTitle) {
    try {
      // 使用传入的标题，非空则用，否则兜底
      String title = chapterTitle.trim().isNotEmpty ? chapterTitle.trim() : '第${chapterIndex + 1}章';

      String preview = '';
      final sentences = bookController.getSentenceFromIndex(chapterIndex);
      if (sentences != null) {
        for (var s in sentences) {
          String clean = _cleanText(_sentenceToString(s));
          if (clean.isNotEmpty) {
            preview = clean.substring(0, math.min(clean.length, 20));
            break;
          }
        }
      }

      final time = DateTime.now().toIso8601String();
      log.i('Time: $time | Title: $title | Preview: "$preview..."', tag: _TAG);
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