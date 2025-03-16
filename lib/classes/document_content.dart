class DocumentContent {
  final String type;
  final List<DocumentChild> children;

  DocumentContent({
    required this.type,
    required this.children,
  });

  factory DocumentContent.fromJson(Map<String, dynamic> json) {
    return DocumentContent(
      type: json['type'],
      children: (json['children'] as List<dynamic>)
          .map((child) => DocumentChild.fromJson(child))
          .toList(),
    );
  }

  static List<DocumentContent> fromDocument(List<dynamic> document) {
    return document.map((json) => DocumentContent.fromJson(json)).toList();
  }
}

class DocumentChild {
  final String text;

  DocumentChild({required this.text});

  factory DocumentChild.fromJson(Map<String, dynamic> json) {
    return DocumentChild(
      text: json['text'] ?? '',
    );
  }
}
