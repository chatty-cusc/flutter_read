// bookshelf_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for ValueNotifier
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert'; // 👈 必须导入以使用 utf8.decode
import 'read_screen.dart';

// 👇 使用 ValueNotifier 管理可变书单（支持动态删除）
final ValueNotifier<List<String>> localBooks = ValueNotifier([
  '斗破苍穹.txt',
  '凡人修仙传.txt',
  '遮天.txt',
  '完美世界.txt',
]);

class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        backgroundColor: const Color(0xFFE2E8DC), // ✅ 正确颜色格式
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFE2E8DC), // ✅ 正确颜色格式
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '本地书籍',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: localBooks,
                builder: (context, books, child) {
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final filename = books[index];
                      final title = filename.replaceAll('.txt', '');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            // === 主内容区（点击进入阅读）===
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadScreen( // ✅ 正确类名
                                      bookAssetPath: 'assets/books/$filename',
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.menu_book,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // === .txt 标签（右上角）===
                            Positioned(
                              top: 15,
                              right: 15,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50]?.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: const Text(
                                  '.txt',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // === “阅读中”状态（左下角）===
                            const Positioned(
                              bottom: 16,
                              left: 75,
                              child: Text(
                                '阅读中',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            // === 三点菜单（右下角）===
                            Positioned(
                              bottom: 2,
                              right: 8,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                color: Colors.white,
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    // ✅ 从书架移除（逻辑删除）
                                    final newList = List<String>.from(books)..removeAt(index);
                                    localBooks.value = newList;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('《$title》已从书架移除'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } else if (value == 'share') {
                                    // ✅ 分享：正确解码 UTF-8，避免乱码
                                    try {
                                      final data = await rootBundle.load('assets/books/$filename');
                                      // 👇 关键修复：使用 utf8.decode 而非 String.fromCharCodes
                                      final text = utf8.decode(data.buffer.asUint8List());

                                      // 限制长度防止系统卡顿或分享失败
                                      final shareText = text.length > 5000
                                          ? '《$title》\n\n${text.substring(0, 5000)}...'
                                          : '《$title》\n\n$text';

                                      await Share.share(
                                        shareText,
                                        subject: '分享书籍：$title',
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('分享失败: $e')),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('从书架移除'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'share',
                                    child: Text('分享'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}