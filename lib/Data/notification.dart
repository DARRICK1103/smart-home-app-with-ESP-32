class notification {
  final String title;
  final String content;
  final String url;
  final String datetime;

  notification({
    required this.title,
    required this.content,
    required this.url,
    required this.datetime,
  });

  notification.fromJson(Map<String, Object?> json)
      : this(
          title: json['Title']! as String,
          content: json['Content']! as String,
          url: json['URL']! as String,
          datetime: json['Datetime']! as String,
        );

  notification copywith({
    String? title,
    String? content,
    String? url,
    String? datetime,
  }) {
    return notification(
      title: title ?? this.title,
      content: content ?? this.content,
      url: url ?? this.url,
      datetime: datetime ?? this.datetime,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'Title': title,
      'Content': content,
      'URL': url,
      'Datetime': datetime,
    };
  }
}
