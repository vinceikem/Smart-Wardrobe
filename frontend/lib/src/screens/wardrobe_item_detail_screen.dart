import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../models/wardrobe_item.dart' as WardrobeItemModel;
import '../providers/wardrobe_provider.dart';

class WardrobeItemDetailScreen extends StatelessWidget {
  final WardrobeItemModel.WardrobeItem item;

  const WardrobeItemDetailScreen({super.key, required this.item});

  // Helper method to show the confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    final String categoryDisplay = item.category;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to permanently delete this $categoryDisplay item? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () {
                // Perform deletion and navigate back
                Provider.of<WardrobeProvider>(
                  context,
                  listen: false,
                ).deleteItem(item.id);

                // Pop the confirmation dialog, then pop the detail screen
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$categoryDisplay item deleted successfully.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve image data (Uint8List) directly from the item object
    final Uint8List? imageData = item.imageData;
    final bool hasImageData = imageData != null && imageData.isNotEmpty;
    final String categoryDisplay = item.category;

    Widget imageWidget = Center(
      child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[600]),
    );

    if (hasImageData) {
      imageWidget = Image.memory(
        imageData,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.broken_image, size: 80, color: Colors.grey[600]),
          );
        },
      );
    }

    // Determine the bottom padding to push content above the delete button
    final double systemSafeAreaBottom = MediaQuery.of(context).padding.bottom;
    const double buttonHeight = 60.0;
    const double verticalMargin = 40.0;
    final double bottomPadding =
        systemSafeAreaBottom + buttonHeight + verticalMargin;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Sleek background
      appBar: AppBar(
        title: const Text(
          'Item Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Image Display with Sleek Styling ---
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors
                        .grey[200], // Light background for image container
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 1, // Square image container
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: imageWidget,
                    ),
                  ),
                ),

                // --- Details Section ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Row(
                          children: [
                            Icon(
                              Icons.checkroom,
                              color: Colors.pinkAccent,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              categoryDisplay,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30),

                        // Date Added
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date Added',
                          value: DateFormat(
                            'EEEE, MMM d, yyyy',
                          ).format(item.createdAt),
                        ),
                        const SizedBox(height: 16),

                        // Item ID (Hidden in the previous design, now cleaner)
                        _buildDetailRow(
                          icon: Icons.fingerprint,
                          label: 'Unique ID',
                          value: item.id,
                          fontSize: 14,
                          valueColor: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Fixed Delete Button at the Bottom (Sleek Red) ---
          Positioned(
            bottom: systemSafeAreaBottom + 16,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(Icons.delete_forever),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Delete Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.red.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build consistent detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    double fontSize = 18,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.pinkAccent.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
