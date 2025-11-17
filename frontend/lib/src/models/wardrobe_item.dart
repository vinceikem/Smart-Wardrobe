import 'package:flutter/material.dart';

// Categories for wardrobe items
enum Category {
  top('Top'),
  bottom('Bottom'),
  shoe('Shoe'),
  accessory('Accessory');

  final String display;
  const Category(this.display);
}

// Model for a single wardrobe item, using Color for simple UI visualization
class WardrobeItem {
  final String id;
  final Category category;
  final Color visualColor; // Used as a visual placeholder for the image/item

  WardrobeItem({
    required this.id,
    required this.category,
    required this.visualColor,
  });
}