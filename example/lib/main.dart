// main.dart
import 'package:flutter/material.dart';
import 'bookshelf_screen.dart'; // 新增导入

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小说阅读器',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE2E8DC),
      ),
      home: const BookshelfScreen(), // 默认进入书架
    );
  }
}