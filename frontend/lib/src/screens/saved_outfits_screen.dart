import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/saved_outfit.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';

class SavedOutfitsScreen extends StatelessWidget {
  const SavedOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedOutfits = context.watch<WardrobeProvider>().savedOutfits;
    final provider = context.read<WardrobeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Outfits'),
      ),
      body: savedOutfits.isEmpty
          ? const Center(
              child: Text(
                'No outfits saved yet.\nGenerate one and click "Save!"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: savedOutfits.length,
              itemBuilder: (context, index) {
                final outfit = savedOutfits[index];
                return SavedOutfitCard(outfit: outfit, provider: provider);
              },
            ),
    );
  }
}

class SavedOutfitCard extends StatelessWidget {
  final SavedOutfit outfit;
  final WardrobeProvider provider;
  
  const SavedOutfitCard({
    required this.outfit,
    required this.provider,
    super.key,
  });
  
  List<WardrobeItem> get items {
    return outfit.itemIds
        .map((id) => provider.getItemById(id))
        .whereType<WardrobeItem>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${outfit.style} Style',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            Text(
              'For: ${outfit.event}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              // NOTE: Requires 'intl' package for DateFormat
              'Saved: ${DateFormat('MMM d, yyyy').format(outfit.dateSaved)}', 
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const Divider(height: 20),
            Text(
              'Description: ${outfit.description}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            
            // Item Stack Display
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: item.visualColor, // Use item color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        item.category.display.substring(0, 1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}