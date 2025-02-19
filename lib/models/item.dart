import 'package:flutter/material.dart';

class Item {
  final String id;
  final String label;
  final IconData icon;

  static final iconMapping = {
    'water_drop': Icons.water_drop,
    'local_fire_department': Icons.local_fire_department,
    'air': Icons.air,
    'terrain': Icons.terrain,
  };

  static IconData getIcon(String iconName) {
    return iconMapping[iconName] ?? Icons.abc; // Thêm giá trị mặc định
  }

  Item({
    required this.id,
    required this.label,
    required this.icon,
  });

  List<String> combinable = [];

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      label: json['name'],
      icon: getIcon(json['icon']),
    );
  }
}