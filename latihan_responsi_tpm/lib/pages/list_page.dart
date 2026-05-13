import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controllers/list_controller.dart';
import '../models/article_model.dart';

/// Halaman Kedua — List News / Blog / Report.
/// Sesuai screenshot: dark AppBar, card putih dengan gambar full-width di atas,
/// judul bold, news_site italic, tanggal + arrow di bawah.
class ListPage extends StatefulWidget {
  final String category;
  final String username;

  const ListPage({super.key, required this.category, required this.username});

  factory ListPage.fromArgs() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return ListPage(
      category: (args['category'] as String?) ?? 'news',
      username: (args['username'] as String?) ?? 'User',
    );
  }

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final ListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ListController(category: widget.category),
      tag: widget.category,
    );
  }

  @override
  void dispose() {
    Get.delete<ListController>(tag: widget.category, force: true);
    super.dispose();
  }

  String get _appBarTitle {
    switch (widget.category.toLowerCase()) {
      case 'news':
        return 'Berita Terkini';
      case 'blog':
      case 'blogs':
        return 'Blog Terkini';
      case 'report':
        return 'Report Terkini';
      default:
        return 'Data';
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text(_appBarTitle)),
      body: Obx(() {
        // ── Loading ─────────────────────────────────────
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }

        // ── Error ────────────────────────────────────────
        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _controller.errorMessage.value,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _controller.fetchItems,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Empty ────────────────────────────────────────
        if (_controller.items.isEmpty) {
          return const Center(
            child: Text('Tidak ada data tersedia',
                style: TextStyle(color: Colors.grey)),
          );
        }

        // ── List ─────────────────────────────────────────
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          itemCount: _controller.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) =>
              _buildItemCard(_controller.items[index]),
        );
      }),
    );
  }

  Widget _buildItemCard(ArticleModel item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () => Get.toNamed(
          '/detail',
          arguments: {'id': item.id, 'category': widget.category},
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar full-width ──────────────────────────
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 190,
                color: const Color(0xFFEDE7FF),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF), strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 190,
                color: const Color(0xFFEDE7FF),
                child: const Icon(Icons.broken_image_rounded,
                    size: 48, color: Color(0xFF6C63FF)),
              ),
            ),

            // ── Konten teks ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Sumber (news_site)
                  Text(
                    item.newsSite,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tanggal + arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(item.publishedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Color(0xFF6C63FF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
