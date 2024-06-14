class Component {
  final String type;
  final Map<String, dynamic> content;
  final Map<String, dynamic>? style;
  final Map<String, dynamic>? action;

  Component({required this.type, required this.content, this.style, this.action});

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      type: json['type'],
      content: json['content'],
      style: json['style'],
      action: json['action'],
    );
  }
}