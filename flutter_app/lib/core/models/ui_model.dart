import 'dart:convert';

/// Represents a UI component from the dynamic UI system
class UIComponent {
  final String type;
  final Map<String, dynamic> properties;
  final List<UIComponent> children;
  final Map<String, dynamic> actions;
  final Map<String, dynamic> styles;

  UIComponent({
    required this.type,
    this.properties = const {},
    this.children = const [],
    this.actions = const {},
    this.styles = const {},
  });

  factory UIComponent.fromJson(Map<String, dynamic> json) {
    List<UIComponent> childrenList = [];
    if (json['children'] != null) {
      childrenList = List<UIComponent>.from(
        json['children'].map((child) => UIComponent.fromJson(child)),
      );
    }

    return UIComponent(
      type: json['type'] ?? 'container',
      properties: json['properties'] ?? {},
      children: childrenList,
      actions: json['actions'] ?? {},
      styles: json['styles'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties,
      'children': children.map((child) => child.toJson()).toList(),
      'actions': actions,
      'styles': styles,
    };
  }
}

/// Represents a complete UI page from the dynamic UI system
class UIPage {
  final String id;
  final String name;
  final String version;
  final UIComponent rootComponent;
  final Map<String, dynamic> metadata;

  UIPage({
    required this.id,
    required this.name,
    required this.version,
    required this.rootComponent,
    this.metadata = const {},
  });

  factory UIPage.fromJson(Map<String, dynamic> json) {
    return UIPage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      version: json['version'] ?? '1.0',
      rootComponent: UIComponent.fromJson(json['rootComponent'] ?? {'type': 'container'}),
      metadata: json['metadata'] ?? {},
    );
  }

  factory UIPage.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UIPage.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'rootComponent': rootComponent.toJson(),
      'metadata': metadata,
    };
  }
}