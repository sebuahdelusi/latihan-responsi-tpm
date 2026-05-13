import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../controllers/detail_controller.dart';

class DetailPage extends StatefulWidget {
  final int itemId;
  final String category;

  const DetailPage({super.key, required this.itemId, required this.category});

  factory DetailPage.fromArgs() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return DetailPage(
      itemId: (args['id'] as int?) ?? 0,
      category: (args['category'] as String?) ?? 'news',
    );
  }

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final DetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      DetailController(category: widget.category, itemId: widget.itemId),
      tag: '${widget.category}-${widget.itemId}',
    );
  }

  @override
  void dispose() {
    Get.delete<DetailController>(
      tag: '${widget.category}-${widget.itemId}',
      force: true,
    );
    super.dispose();
  }

  String get _appBarTitle {
    switch (widget.category.toLowerCase()) {
      case 'news':
        return 'News Detail';
      case 'blog':
      case 'blogs':
        return 'Blog Detail';
      case 'report':
        return 'Report Detail';
      default:
        return 'Detail';
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka URL'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(_appBarTitle)),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }

        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Gagal memuat detail',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(_controller.errorMessage.value,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        final item = _controller.item.value;
        if (item == null) {
          return const Center(
            child: Text('Data tidak ditemukan',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 240,
                      color: const Color(0xFFEDE7FF),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF), strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 240,
                      color: const Color(0xFFEDE7FF),
                      child: const Icon(Icons.broken_image_rounded,
                          size: 64, color: Color(0xFF6C63FF)),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          item.newsSite,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          _formatDate(item.publishedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),

                        Text(
                          item.summary,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF333333),
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () => _openUrl(item.url),
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                label: const Text(
                  'See more..',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
