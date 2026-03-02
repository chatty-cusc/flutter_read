// read_screen.dart
import 'dart:async';
import 'dart:convert';
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

  // 👇 新增：存储真实章节标题
  List<String> _chapterTitles = [];

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
      final content = utf8.decode(data.buffer.asUint8List());

      // 👇 提取所有章节标题
      final titleRegex = RegExp(
        r'^\s*(第[零一二三四五六七八九十百\d]+[章节卷节部篇].*|引子|序章|楔子|尾声|Epilogue|Prologue.*)',
        multiLine: true,
        caseSensitive: false,
      );
      _chapterTitles = titleRegex.allMatches(content).map((m) {
        return m.group(0)!.trim();
      }).toList();

      // 如果没找到标题，至少保证长度匹配（避免越界）
      if (_chapterTitles.isEmpty) {
        _chapterTitles = ['第一章'];
      }

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
      // 👇 直接使用预提取的标题
      String title = chapterIndex < _chapterTitles.length
          ? _chapterTitles[chapterIndex]
          : '第${chapterIndex + 1}章';

      String preview = '';
      final sentences = bookController.getSentenceFromIndex(chapterIndex);
      if (sentences != null && sentences.isNotEmpty) {
        // 找第一个非空句子作为预览
        for (var s in sentences) {
          String text = _trimLeadingWhitespace(_sentenceToString(s));
          if (text.isNotEmpty) {
            preview = text.substring(0, math.min(text.length, 20));
            break;
          }
        }
      }

      final time = DateTime.now().toIso8601String();
      final sep = '-' * 120;
      log.i(sep, tag: _TAG);
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