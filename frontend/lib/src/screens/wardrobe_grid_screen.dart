import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';

class WardrobeGridScreen extends StatelessWidget {
  const WardrobeGridScreen({super.key});

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
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<WardrobeProvider>().items.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe Items'),
      ),
      body: items.isEmpty
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
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return WardrobeGridCard(
                  item: item,
                  icon: _getCategoryIcon(item.category),
                );
              },
            ),
    );
  }
}

class WardrobeGridCard extends StatelessWidget {
  final WardrobeItem item;
  final IconData icon;

  const WardrobeGridCard({
    required this.item,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: item.visualColor, // Use the visualColor
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 64,
                  color: Colors.white,
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
                  item.category.display,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Color ID: ${item.visualColor.value.toRadixString(16).toUpperCase().substring(2)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
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