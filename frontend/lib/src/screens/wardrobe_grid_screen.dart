// wardrobe_grid_screen.dart (Modified File)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/wardrobe_item_2.dart';
import '../models/wardrobe_item.dart' as WardrobeItemModel;
import '../providers/wardrobe_provider.dart';
import 'wardrobe_item_detail_screen.dart'; // <-- New Import

class WardrobeGridScreen extends StatelessWidget {
  const WardrobeGridScreen({super.key});

  // ... (Keep _getCategoryIcon and _getCategoryEnum methods here) ...

  IconData _getCategoryIcon(Category cat) {
    switch (cat) {
      case Category.top:
        return Icons.catching_pokemon;
      case Category.bottom:
        return Icons.straighten;
      case Category.shoe:
        return Icons.shower;
      case Category.accessory:
        return Icons.watch_outlined;
    }
  }

  Category _getCategoryEnum(String categoryString) {
    try {
      return Category.values.firstWhere(
        (e) => e.toString().split('.').last == categoryString,
        orElse: () => Category.top,
      );
    } catch (e) {
      return Category.top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<WardrobeProvider>().items;
    final displayItems = items.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Wardrobe Items')),
      body: displayItems.isEmpty
          ? const Center(
              child: Text(
                'Your wardrobe is empty!\nAdd your first item.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.8,
              ),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final item =
                    displayItems[index] as WardrobeItemModel.WardrobeItem;
                final categoryEnum = _getCategoryEnum(item.category);

                return GestureDetector(
                  // <-- WRAP CARD IN DETECTOR
                  onTap: () {
                    // Navigate to the detail screen on tap
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => WardrobeItemDetailScreen(
                          item: item,
                          categoryEnum: categoryEnum,
                        ),
                      ),
                    );
                  },
                  child: WardrobeGridCard(
                    item: item,
                    icon: _getCategoryIcon(categoryEnum),
                    categoryEnum: categoryEnum,
                  ),
                );
              },
            ),
    );
  }
}

// Keep WardrobeGridCard definition below (it doesn't need changes from the last iteration)
class WardrobeGridCard extends StatelessWidget {
  final WardrobeItemModel.WardrobeItem item;
  final IconData icon;
  final Category categoryEnum;

  const WardrobeGridCard({
    required this.item,
    required this.icon,
    required this.categoryEnum,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imageFile = File(item.imagePath);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageFile.existsSync()
                    ? Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              icon,
                              size: 64,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          icon,
                          size: 64,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryEnum.display,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Added: ${DateFormat('MMM d, yyyy').format(item.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
