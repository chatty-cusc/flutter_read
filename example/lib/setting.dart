import 'package:flutter/material.dart';
import 'package:flutter_read/flutter_read.dart';

class BookSetting extends StatefulWidget {
  final ReadController bookController;

  const BookSetting({super.key, required this.bookController});

  @override
  State<BookSetting> createState() => _BookSettingState();
}

class _BookSettingState extends State<BookSetting> {
  static const double _circleSize = 40.0;
  static const double _spacing = 8.0;
  static const double _trailingWidth = _circleSize * 3 + _spacing * 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _fontSize(),
          const SizedBox(height: 6),
          _lineSpacing(),
          const SizedBox(height: 6),
          _wordSpacing(),
          const SizedBox(height: 6),
          _fontColor(),
          const SizedBox(height: 6),
          _fontFamily(),
        ],
      ),
    );
  }

  Widget _buildThreeSlotTrailing({
    required Widget? left,
    Widget? middle,
    required Widget? right,
  }) {
    middle ??= const SizedBox.shrink();
    return SizedBox(
      width: _trailingWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          left ?? const SizedBox.shrink(),
          middle,
          right ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  // 字体大小
  Widget _fontSize() {
    final currentStyle = widget.bookController.readStyle;
    final fontSize = currentStyle.textStyle.fontSize ?? 16;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -3),
      dense: true,
      title: const Text("字体大小", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: _buildThreeSlotTrailing(
        left: _buildCircleButton("A-", () {
          setState(() {
            widget.bookController.readStyle = currentStyle.copyWith(
              textStyle: currentStyle.textStyle.copyWith(fontSize: fontSize - 1),
              titleTextStyle: currentStyle.titleTextStyle.copyWith(fontSize: (fontSize - 1) * 1.3),
            );
          });
        }),
        middle: Text("$fontSize", style: const TextStyle(fontSize: 12)),
        right: _buildCircleButton("A+", () {
          setState(() {
            widget.bookController.readStyle = currentStyle.copyWith(
              textStyle: currentStyle.textStyle.copyWith(fontSize: fontSize + 1),
              titleTextStyle: currentStyle.titleTextStyle.copyWith(fontSize: (fontSize + 1) * 1.3),
            );
          });
        }),
      ),
    );
  }

  // 行距
  Widget _lineSpacing() {
    final currentStyle = widget.bookController.readStyle;
    final lineSpacing = currentStyle.lineSpacing;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -3),
      dense: true,
      title: const Text("行距", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: _buildThreeSlotTrailing(
        left: _buildCircleButton("≡-", () {
          setState(() {
            widget.bookController.readStyle = currentStyle.copyWith(lineSpacing: lineSpacing - 1);
          });
        }),
        middle: Text("$lineSpacing", style: const TextStyle(fontSize: 12)),
        right: _buildCircleButton("≡+", () {
          setState(() {
            widget.bookController.readStyle = currentStyle.copyWith(lineSpacing: lineSpacing + 1);
          });
        }),
      ),
    );
  }

  // 字间距
  Widget _wordSpacing() {
    final currentStyle = widget.bookController.readStyle;
    final wordSpacing = currentStyle.wordSpacing;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -3),
      dense: true,
      title: const Text("字间距", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: _buildThreeSlotTrailing(
        left: _buildCircleButton("W-", () {
          setState(() {
            widget.bookController.readStyle = currentStyle.copyWith(wordSpacing: wordSpacing - 1);
          });
        }),
        middle: Text("$wordSpacing", style: const TextStyle(fontSize: 12)),
        right: _buildCircleButton("W+", () {
          setState(() {
            widget.bookController.readStyle = currentStyle.copyWith(wordSpacing: wordSpacing + 1);
          });
        }),
      ),
    );
  }

  // 背景色
  Widget _fontColor() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -3),
      dense: true,
      title: const Text("背景色", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: _buildThreeSlotTrailing(
        left: _buildColorCircle(const Color(0xFFF5F5DC), const Color(0xFF212832)),
        middle: _buildColorCircle(const Color(0xFFC7EDCC), const Color(0xFF333333)),
        right: _buildColorCircle(const Color(0xFF1E1E1E), const Color(0xFFCCCCCC)),
      ),
    );
  }

  Widget _buildColorCircle(Color bgColor, Color textColor) {
    final currentStyle = widget.bookController.readStyle;
    bool isSelected = currentStyle.bgColor == bgColor;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.bookController.readStyle = currentStyle.copyWith(
            bgColor: bgColor,
            textStyle: currentStyle.textStyle.copyWith(color: textColor),
            titleTextStyle: currentStyle.titleTextStyle.copyWith(color: textColor),
          );
        });
      },
      child: Container(
        width: _circleSize,
        height: _circleSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "T",
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 字体
  Widget _fontFamily() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -3),
      dense: true,
      title: const Text("字体", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: _buildThreeSlotTrailing(
        left: _buildFontCircle("系统", ""),
        middle: const SizedBox.shrink(),
        right: _buildFontCircle("楷体", "楷体"),
      ),
    );
  }

  Widget _buildFontCircle(String displayText, String fontFamily) {
    final currentStyle = widget.bookController.readStyle;
    bool isSelected = (currentStyle.textStyle.fontFamily ?? '') == fontFamily;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.bookController.readStyle = currentStyle.copyWith(
            textStyle: currentStyle.textStyle.copyWith(fontFamily: fontFamily.isEmpty ? null : fontFamily),
            titleTextStyle: currentStyle.titleTextStyle.copyWith(fontFamily: fontFamily.isEmpty ? null : fontFamily),
          );
        });
      },
      child: Container(
        width: _circleSize,
        height: _circleSize,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[100],
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: fontFamily.isEmpty ? null : fontFamily,
            color: isSelected ? Colors.blue[800] : Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _circleSize,
        height: _circleSize,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue[300]!, width: 1.2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}