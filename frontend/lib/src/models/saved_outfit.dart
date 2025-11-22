import 'package:hive/hive.dart';

part 'saved_outfit.g.dart'; // Remember to run 'flutter pub run build_runner build'

@HiveType(typeId: 1) // Ensure this typeId is unique across your application
class SavedOutfit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String style;

  @HiveField(3)
  final String event;

  @HiveField(4)
  final DateTime dateSaved;

  @HiveField(5)
  final List<String> itemIds; // List of IDs of the WardrobeItems used

  @HiveField(6)
  final String imageUrl; // URL to the generated outfit image

  SavedOutfit({
    required this.id,
    this.description = '',
    required this.style,
    required this.event,
    required this.dateSaved,
    required this.itemIds,
    required this.imageUrl,
  });

  /// The key used for storing in Hive: "outfit- `<`id>"
  @override
  String get key => 'outfit-$id';
}
