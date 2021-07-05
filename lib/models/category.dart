import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:social_media_app/models/enum/message_type.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final int display_order;
  final String color;
  final List<Category> subcategories =null;

  Category({
    this.id,
    this.name,
    this.description,
    this.display_order,
    this.color,
    subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      display_order: json['display_order'],
      color: json['color'],
      subcategories:[],
    );
  }
}
