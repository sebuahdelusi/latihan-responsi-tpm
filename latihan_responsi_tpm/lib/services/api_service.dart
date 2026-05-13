import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

/// Service untuk mengakses Spaceflight News API v4.
///
/// Endpoints:
///   - Articles (News): /v4/articles/
///   - Blogs:           /v4/blogs/
///   - Reports:         /v4/reports/
///   - Detail:          /v4/{menu}/{id}/
class ApiService {
  static const String _baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  /// Mengembalikan endpoint path berdasarkan kategori.
  static String _endpointFor(String category) {
    switch (category.toLowerCase()) {
      case 'news':
        return 'articles';
      case 'blog':
      case 'blogs':
        return 'blogs';
      case 'report':
        return 'reports';
      default:
        return 'articles';
    }
  }

  /// Mengambil list data (articles / blogs / reports).
  /// [category] = 'news' | 'blogs' | 'report'
  static Future<List<ArticleModel>> fetchList(String category,
      {int limit = 10, int offset = 0}) async {
    final endpoint = _endpointFor(category);
    final url = Uri.parse('$_baseUrl/$endpoint/?limit=$limit&offset=$offset');
    final client = http.Client();
    try {
      debugPrint('GET $url');
      final response = await client
          .get(
            url,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'Mozilla/5.0',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return compute(_parseList, response.body);
      } else {
        throw HttpException(
          'HTTP ${response.statusCode} ${response.reasonPhrase ?? ''}',
          uri: url,
        );
      }
    } on TimeoutException catch (e) {
      throw TimeoutException('Timeout saat memuat data $category', e.duration);
    } on SocketException catch (e) {
      throw SocketException('Koneksi bermasalah: ${e.message}');
    } finally {
      client.close();
    }
  }

  /// Mengambil detail satu item berdasarkan [id] dan [category].
  static Future<ArticleModel> fetchDetail(String category, int id) async {
    final endpoint = _endpointFor(category);
    final url = Uri.parse('$_baseUrl/$endpoint/$id/');
    final client = http.Client();
    try {
      debugPrint('GET $url');
      final response = await client
          .get(
            url,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'Mozilla/5.0',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return compute(_parseDetail, response.body);
      } else {
        throw HttpException(
          'HTTP ${response.statusCode} ${response.reasonPhrase ?? ''}',
          uri: url,
        );
      }
    } on TimeoutException catch (e) {
      throw TimeoutException('Timeout saat memuat detail $category', e.duration);
    } on SocketException catch (e) {
      throw SocketException('Koneksi bermasalah: ${e.message}');
    } finally {
      client.close();
    }
  }
}

List<ArticleModel> _parseList(String body) {
  final data = json.decode(body) as Map<String, dynamic>;
  final results = data['results'] as List<dynamic>;
  return results.map((item) => ArticleModel.fromJson(item)).toList();
}

ArticleModel _parseDetail(String body) {
  final data = json.decode(body) as Map<String, dynamic>;
  return ArticleModel.fromJson(data);
}
