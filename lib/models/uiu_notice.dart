class UIUNotice {
  final String id;
  final String title;
  final String link;
  final String pubDate;
  final String description;
  final bool isRead;

  const UIUNotice({
    required this.id,
    required this.title,
    required this.link,
    required this.pubDate,
    required this.description,
    this.isRead = false,
  });

  UIUNotice copyWith({
    String? id,
    String? title,
    String? link,
    String? pubDate,
    String? description,
    bool? isRead,
  }) {
    return UIUNotice(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      pubDate: pubDate ?? this.pubDate,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'link': link,
        'pubDate': pubDate,
        'description': description,
        'isRead': isRead,
      };

  factory UIUNotice.fromJson(Map<String, dynamic> json) => UIUNotice(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        link: json['link'] ?? '',
        pubDate: json['pubDate'] ?? '',
        description: json['description'] ?? '',
        isRead: json['isRead'] ?? false,
      );
}
