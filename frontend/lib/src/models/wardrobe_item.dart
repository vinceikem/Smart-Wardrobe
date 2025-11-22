import 'package:hive/hive.dart';

part 'wardrobe_item.g.dart';

@HiveType(typeId: 0)
class WardrobeItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final DateTime createdAt;

  WardrobeItem({
    required this.id,
    required this.category,
    required this.imagePath,
    required this.createdAt,
  });

  /// Key format used throughout the app: "<category>-<id>"
  String get key => '$category-$id';
}