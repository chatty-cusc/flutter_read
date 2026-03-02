import 'package:flutter/material.dart';
import 'package:flutter_read/flutter_read.dart';
import 'package:flutter_read_example/setting.dart';

class BookMenu extends StatefulWidget {
  final ReadController bookController;

  const BookMenu({super.key, required this.bookController});

  @override
  State<BookMenu> createState() => _BookMenuState();
}

class _BookMenuState extends State<BookMenu> {
  bool _showDirectoryFlag = false;
  bool _showSettingFlag = false;
  bool _wrapDirectoryHeight = true;
  bool _wrapSettingHeight = true;
  final int _animDuration = 250;

  void _showDirectory() {
    setState(() {
      _showDirectoryFlag = true;
      _wrapDirectoryHeight = false;
    });
  }

  void _closeDirectory() {
    setState(() {
      _showDirectoryFlag = false;
    });
  }

  void _showSetting() {
    setState(() {
      _showSettingFlag = true;
      _wrapSettingHeight = false;
    });
  }

  void _closeSetting() {
    setState(() {
      _showSettingFlag = false;
    });
  }

  // 🔍 根据 currentBookSource 的标题反查当前章节索引
  int _getCurrentChapterIndex() {
    final currentSource = widget.bookController.currentBookSource;
    if (currentSource == null) return 0;

    final total = widget.bookController.getChapterNum();
    for (int i = 0; i < total; i++) {
      final source = widget.bookController.getSourceFromIndex(i);
      if (source?.getTitle() == currentSource.getTitle()) {
        return i;
      }
    }
    return 0; // 默认返回第一章
  }

  @override
  Widget build(BuildContext context) {
    bool wrap = _wrapDirectoryHeight;
    return SizedBox(
      width: double.infinity,
      height: wrap ? null : double.infinity,
      child: Stack(
        fit: wrap ? StackFit.loose : StackFit.expand,
        children: [
          if (!wrap)
            GestureDetector(
              onTap: () {
                if (_showDirectoryFlag) {
                  _closeDirectory();
                }
                if (_showSettingFlag) {
                  _closeSetting();
                }
              },
              child: AnimatedOpacity(
                opacity: _showDirectoryFlag || _showSettingFlag ? 1 : 0,
                duration: Duration(milliseconds: _animDuration),
                onEnd: () {
                  if (!_showDirectoryFlag) {
                    setState(() {
                      _wrapDirectoryHeight = true;
                    });
                  }
                  if (!_showSettingFlag) {
                    setState(() {
                      _wrapSettingHeight = true;
                    });
                  }
                },
                child: const ColoredBox(
                  color: Color(0x80000000),
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  AnimatedSlide(
                    offset: _wrapDirectoryHeight || !_showDirectoryFlag
                        ? const Offset(0, 1)
                        : Offset.zero,
                    duration: Duration(milliseconds: _animDuration),
                    child: SizedBox(
                      height: !_wrapDirectoryHeight ? 360 : 0,
                      child: _buildDirectory(),
                    ),
                  ),
                  AnimatedSlide(
                    offset: _wrapSettingHeight || !_showSettingFlag
                        ? const Offset(0, 1)
                        : Offset.zero,
                    duration: Duration(milliseconds: _animDuration),
                    child: SizedBox(
                      height: !_wrapSettingHeight ? 250 : 0,
                      child: BookSetting(
                        bookController: widget.bookController,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 1,
                color: Colors.amberAccent,
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _item("目录", "", () {
                      if (_showSettingFlag) {
                        _closeSetting();
                      }
                      if (_showDirectoryFlag) {
                        _closeDirectory();
                      } else {
                        _showDirectory();
                      }
                    }),
                    Container(
                      width: 1,
                      color: Colors.amberAccent,
                    ),
                    _item("设置", "", () {
                      if (_showDirectoryFlag) {
                        _closeDirectory();
                      }
                      if (_showSettingFlag) {
                        _closeSetting();
                      } else {
                        _showSetting();
                      }
                    }),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(String text, String icon, GestureTapCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: const Color.fromARGB(255, 206, 204, 204),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectory() {
    final currentChapterIndex = _getCurrentChapterIndex();
    const double itemHeight = 60.0; // 固定每行高度
    final scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        // 滚动到当前章节顶部（使其成为第一行）
        scrollController.animateTo(
          currentChapterIndex * itemHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              widget.bookController.currentBookSource?.getTitle() ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            height: 1,
            color: Colors.amberAccent,
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: widget.bookController.getChapterNum(),
              // ✅ 关键：只保留水平 padding，避免垂直干扰滚动
              padding: const EdgeInsets.symmetric(horizontal: 10),
              // ✅ 关键：固定每项高度
              itemExtent: itemHeight,
              itemBuilder: (context, index) {
                BookSource? source = widget.bookController.getSourceFromIndex(index);
                final isSelected = index == currentChapterIndex;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(source?.getTitle() ?? ""),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  tileColor: isSelected ? Colors.blue[50] : null,
                  onTap: () {
                    _closeDirectory();
                    Future.delayed(Duration(milliseconds: _animDuration), () {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      widget.bookController.startReadChapter(
                        source!,
                        ChapterData(chapterIndex: index),
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}