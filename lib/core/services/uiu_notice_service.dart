import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/uiu_notice.dart';

class UIUNoticeService extends ChangeNotifier {
  static final UIUNoticeService _instance = UIUNoticeService._internal();
  factory UIUNoticeService() => _instance;
  UIUNoticeService._internal();

  static const String _noticesCacheKey = 'uiu_cached_notices_v1';
  static const String _readIdsKey = 'uiu_read_notice_ids_v1';
  static const List<String> _rssFeedUrls = [
    'https://www.uiu.ac.bd/notice/feed/',
    'https://www.uiu.ac.bd/feed/?post_type=notice',
  ];

  List<UIUNotice> _notices = [];
  Set<String> _readNoticeIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<UIUNotice> get notices => _notices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount =>
      _notices.where((n) => !_readNoticeIds.contains(n.id) && !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  Future<void> init() async {
    await _loadFromLocal();
    // Fetch live feed in background immediately
    fetchLatestNotices();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIdsList = prefs.getStringList(_readIdsKey) ?? [];
      _readNoticeIds = readIdsList.toSet();

      final cachedJson = prefs.getString(_noticesCacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(cachedJson);
        _notices = list.map((item) {
          final notice = UIUNotice.fromJson(Map<String, dynamic>.from(item));
          final isRead = _readNoticeIds.contains(notice.id);
          return notice.copyWith(isRead: isRead);
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached UIU notices: $e');
    }
  }

  Future<void> fetchLatestNotices() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      client.badCertificateCallback = (cert, host, port) => true;

      String? xmlContent;
      for (final url in _rssFeedUrls) {
        try {
          final request = await client.getUrl(Uri.parse(url));
          request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 UIU-CGPA-Calculator/1.0');
          request.headers.set('Accept', 'application/rss+xml, application/xml, text/xml, */*');
          final response = await request.close().timeout(const Duration(seconds: 6));

          if (response.statusCode == 200) {
            xmlContent = await response.transform(utf8.decoder).join();
            if (xmlContent.contains('<item>')) {
              break;
            }
          }
        } catch (e) {
          debugPrint('Error with feed URL $url: $e');
        }
      }

      if (xmlContent != null && xmlContent.isNotEmpty) {
        final parsed = _parseRssFeed(xmlContent);

        if (parsed.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final readIdsList = prefs.getStringList(_readIdsKey) ?? [];
          _readNoticeIds = readIdsList.toSet();

          _notices = parsed.map((n) {
            final isRead = _readNoticeIds.contains(n.id);
            return n.copyWith(isRead: isRead);
          }).toList();

          await prefs.setString(
            _noticesCacheKey,
            jsonEncode(_notices.map((n) => n.toJson()).toList()),
          );
        }
      } else if (_notices.isEmpty) {
        _errorMessage = 'Could not fetch latest notices. Showing offline records.';
      }
    } catch (e) {
      debugPrint('Error fetching UIU notices: $e');
      if (_notices.isEmpty) {
        _errorMessage = 'Could not fetch latest notices. Showing offline records.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UIUNotice> _parseRssFeed(String xml) {
    final results = <UIUNotice>[];
    final itemBlocks = xml.split('<item>');

    for (int i = 1; i < itemBlocks.length; i++) {
      final block = itemBlocks[i];
      final title = _extractTag(block, 'title');
      final link = _extractTag(block, 'link');
      final pubDate = _extractTag(block, 'pubDate');
      final desc = _extractTag(block, 'description');
      final guid = _extractTag(block, 'guid');

      final cleanTitle = _cleanHtml(title);
      final cleanLink = link.trim();
      final cleanPubDate = _formatPubDate(pubDate.trim());
      final cleanDesc = _cleanHtml(desc);
      final id = guid.isNotEmpty ? guid.trim() : (cleanLink.isNotEmpty ? cleanLink : 'notice_$i');

      if (cleanTitle.isNotEmpty) {
        results.add(UIUNotice(
          id: id,
          title: cleanTitle,
          link: cleanLink,
          pubDate: cleanPubDate,
          description: cleanDesc,
          isRead: false,
        ));
      }
    }
    return results;
  }

  String _extractTag(String block, String tag) {
    final cdataRegex = RegExp('<$tag>(?:<!\\[CDATA\\[)?(.*?)(?:\\]\\]>)?<\\/$tag>', dotAll: true);
    final match = cdataRegex.firstMatch(block);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? '';
    }
    final normalRegex = RegExp('<$tag>(.*?)<\\/$tag>', dotAll: true);
    final matchNormal = normalRegex.firstMatch(block);
    return matchNormal?.group(1) ?? '';
  }

  String _cleanHtml(String str) {
    var result = str
        .replaceAll('<![CDATA[', '')
        .replaceAll(']]>', '')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&#8211;', '-')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&#038;', '&')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return result;
  }

  String _formatPubDate(String rawDate) {
    try {
      if (rawDate.isEmpty) return 'Recent';
      // Format: "Wed, 07 Oct 2026 03:40:01 +0000"
      final parts = rawDate.split(' ');
      if (parts.length >= 4) {
        return '${parts[1]} ${parts[2]} ${parts[3]}';
      }
      return rawDate;
    } catch (_) {
      return rawDate;
    }
  }

  Future<void> markAsRead(String id) async {
    _readNoticeIds.add(id);
    _notices = _notices.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readIdsKey, _readNoticeIds.toList());
  }

  Future<void> markAllAsRead() async {
    for (final n in _notices) {
      _readNoticeIds.add(n.id);
    }
    _notices = _notices.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readIdsKey, _readNoticeIds.toList());
  }
}

