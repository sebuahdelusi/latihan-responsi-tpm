import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(HomeController());
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Get.offAllNamed('/login');
    }
  }

  static const _cardBg = Color(0xFFEDE7FF);

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'News',
      'description':
          'Get an overview of the latest SpaceFlight news, from various sources!. Easily link your users to the right websites',
      'icon': Icons.newspaper_rounded,
      'category': 'news',
    },
    {
      'title': 'Blog',
      'description':
          'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast',
      'icon': Icons.article_rounded,
      'category': 'blog',
    },
    {
      'title': 'Report',
      'description':
          'Space stations and other missions often publish their data. With SNAPI, you can include it in your application',
      'icon': Icons.assessment_rounded,
      'category': 'report',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Obx(() => Text('Hai, ${_controller.username.value}!')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        itemCount: _menuItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return _buildMenuCard(
            title: item['title'] as String,
            description: item['description'] as String,
            icon: item['icon'] as IconData,
            onTap: () => Get.toNamed(
              '/list',
              arguments: {
                'category': item['category'] as String,
                'username': _controller.username.value,
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _cardBg,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 30, color: const Color(0xFF6C63FF)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
