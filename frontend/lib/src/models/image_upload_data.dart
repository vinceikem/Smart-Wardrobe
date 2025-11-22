import 'dart:typed_data';

/// A model used specifically for bundling the necessary data
/// for a single image upload to the prompt service.
/// It now includes the item's unique identifier (`id`).
class ImageUploadData {
  /// The unique database ID of the item.
  final String id;

  /// The category of the item (e.g., 'tops', 'bottoms').
  final String category;

  /// The actual image data as bytes.
  final Uint8List? imageData;

  ImageUploadData({
    required this.id,
    required this.category,
    required this.imageData,
  });
}