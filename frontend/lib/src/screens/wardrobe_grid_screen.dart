import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data'; // Required for Uint8List and Image.memory

import '../models/wardrobe_item_2.dart'; // Contains Category enum
import '../models/wardrobe_item.dart'; // Contains Hive Model (WardrobeItem)
import '../providers/wardrobe_provider.dart';
import 'wardrobe_item_detail_screen.dart'; // Detail screen for navigation

class WardrobeGridScreen extends StatelessWidget {
  const WardrobeGridScreen({super.key});

  IconData _getCategoryIcon(Category cat) {
    switch (cat) {
      case Category.top:
        return Icons.checkroom;
      case Category.bottom:
        return Icons.straighten;
      case Category.shoe:
        return Icons.do_not_step;
      case Category.accessory:
        return Icons.watch;
    }
  }

  Category _getCategoryEnum(String categoryString) {
    try {
      return Category.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            categoryString.toLowerCase(),
        orElse: () => Category.top,
      );
    } catch (e) {
      return Category.top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<WardrobeProvider>().items;
    final displayItems = items.cast<WardrobeItem>().reversed.toList();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Sleek background
      appBar: AppBar(
        title: const Text(
          'My Wardrobe',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: displayItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your wardrobe is empty!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first item to get started.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.75, // Taller cards for a better look
              ),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final categoryEnum = _getCategoryEnum(item.category);

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => WardrobeItemDetailScreen(item: item),
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

class WardrobeGridCard extends StatelessWidget {
  final WardrobeItem item;
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
    final Uint8List? imageData = item.imageData;
    final bool hasImageData = imageData != null && imageData.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                color: Colors.grey[50],
                child: hasImageData
                    ? Image.memory(
                        imageData!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              icon,
                              size: 40,
                              color: Colors.grey[300],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(icon, size: 40, color: Colors.grey[300]),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryEnum.display,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d').format(item.createdAt),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
