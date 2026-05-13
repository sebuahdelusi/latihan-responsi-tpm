/// Model untuk data Article, Blog, dan Report dari Spaceflight News API v4.
/// Ketiga endpoint memiliki struktur JSON yang hampir identik,
/// sehingga satu model bisa dipakai untuk semuanya.
class ArticleModel {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String updatedAt;
  final List<Author> authors;

  ArticleModel({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.updatedAt,
    required this.authors,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      newsSite: json['news_site'] ?? '',
      summary: json['summary'] ?? '',
      publishedAt: json['published_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      authors: (json['authors'] as List<dynamic>?)
              ?.map((a) => Author.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap(String category) {
    return {
      'id': id,
      'category': category,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'updated_at': updatedAt,
    };
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      url: map['url'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      newsSite: map['news_site'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      publishedAt: map['published_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
      authors: const [],
    );
  }
}

class Author {
  final String name;

  Author({required this.name});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(name: json['name'] ?? '');
  }
}
