// 2. SavedOutfitsScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/saved_outfit.dart'; // Hive Saved Outfit
import '../models/wardrobe_item.dart' as WardrobeItemModel; // Hive Wardrobe Item
import '../providers/wardrobe_provider.dart';

class SavedOutfitsScreen extends StatelessWidget {
  const SavedOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedOutfits = context.watch<WardrobeProvider>().savedOutfits;
    final provider = context.read<WardrobeProvider>(); // For accessing individual items

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
  
  // NOTE: This getter now returns the Hive Wardrobe Item model
  List<WardrobeItemModel.WardrobeItem> get items {
    // Find WardrobeItems using the IDs stored in the outfit
    return outfit.itemIds
        .map((id) => provider.items.cast<WardrobeItemModel.WardrobeItem?>().firstWhere(
              (item) => item?.id == id,
              orElse: () => null,
            ))
        .whereType<WardrobeItemModel.WardrobeItem>() // Filter out nulls
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Display the Generated Outfit Image prominently
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              outfit.imageUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Center(child: Text('Image Error', style: TextStyle(color: Colors.red))),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${outfit.style} Style',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    Text(
                      // Requires 'intl' package for DateFormat
                      'Saved: ${DateFormat('MMM d, yyyy').format(outfit.dateSaved)}', 
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                Text(
                  'For: ${outfit.event}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const Divider(height: 20),
                Text(
                  'Description: ${outfit.description}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // 3. Item Stack Display (smaller visual confirmation)
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final fileExists = File(item.imagePath).existsSync();

                      return Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          // Use the item image path
                          image: fileExists
                              ? DecorationImage(
                                  image: FileImage(File(item.imagePath)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey.shade300, // Fallback color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: fileExists ? null : const Icon(Icons.image_not_supported, size: 24, color: Colors.white70),
                        ),
                      );
                    },
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