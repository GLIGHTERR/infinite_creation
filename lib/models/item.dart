import 'package:flutter/material.dart';

class Item {
  IconData icon;
  String label;
  List<String> combinable = [];

  Item.withLabel(this.label) : icon = Icons.abc;
}