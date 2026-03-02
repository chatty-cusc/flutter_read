// bookshelf_screen.dart

import 'package:flutter/material.dart';
import 'read_screen.dart';

// 👇 书单：文件名必须与 assets/books/ 下的文件一致
final List<String> localBooks = [
  '斗破苍穹.txt',
  '凡人修仙传.txt',
  '遮天.txt',
  '完美世界.txt',
];

class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        backgroundColor: const Color(0xFFE2E8DC),
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFE2E8DC),
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
              child: ListView.builder(
                itemCount: localBooks.length,
                itemBuilder: (context, index) {
                  final filename = localBooks[index];
                  final title = filename.replaceAll('.txt', '');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // === 主内容区（可点击）===
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadScreen(
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
                                // 封面图
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

                                // 仅保留书名（状态移到 Positioned）
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
                              // ignore: deprecated_member_use
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

                        // === “未读”文字（左下角）✅ 新增 Positioned ===
                        const Positioned(
                          bottom: 16, // 👈 和三点菜单的 bottom 一致
                          left: 75, // 50（封面宽）+ 12（间距）+ 2（安全余量）
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
                          bottom: 2, // 👈 已经是 2
                          right: 8,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            color: Colors.white,
                            onSelected: (value) {
                              if (value == 'delete') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('删除功能待实现')),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('删除'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}