import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'wardrobe_item.g.dart';

@HiveType(typeId: 0)
class WardrobeItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final Uint8List? imageData;

  @HiveField(3)
  final DateTime createdAt;

  WardrobeItem({
    required this.id,
    required this.category,
    required this.imageData,
    required this.createdAt,
  });

  @override
  String get key => '$category-$id';
}
