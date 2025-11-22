// wardrobe_item_detail_screen.dart (New File)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wardrobe_item.dart' as WardrobeItemModel;
import '../models/wardrobe_item_2.dart'; // For Category enum

class WardrobeItemDetailScreen extends StatelessWidget {
  final WardrobeItemModel.WardrobeItem item;
  final Category categoryEnum;

  const WardrobeItemDetailScreen({
    super.key,
    required this.item,
    required this.categoryEnum,
  });

  @override
  Widget build(BuildContext context) {
    final imageFile = File(item.imagePath);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryEnum.display),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Full-Screen Image Display ---
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              color: Colors.grey.shade900,
              child: imageFile.existsSync()
                  ? Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, size: 80, color: Colors.grey[600]),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[600]),
                    ),
            ),
            
            // --- Details Section ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category: ${categoryEnum.display}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Added: ${DateFormat('EEEE, MMM d, yyyy').format(item.createdAt)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ID: ${item.id}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  // Add more details here (e.g., tags, brand, description)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}