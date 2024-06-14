import 'component.dart';

class ScreenModel {
  final String id;
  final String title;
  final List<Component> components;

  ScreenModel({required this.id, required this.title, required this.components});

  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    var componentsFromJson = json['components'] as List;
    List<Component> componentsList = componentsFromJson.map((i) => Component.fromJson(i)).toList();

    return ScreenModel(
      id: json['id'],
      title: json['title'],
      components: componentsList,
    );
  }
}