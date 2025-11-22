import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data'; // Required for Uint8List and MemoryImage

import '../models/saved_outfit.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';
import 'wardrobe_item_detail_screen.dart'; // Detail screen import

class SavedOutfitsScreen extends StatelessWidget {
  const SavedOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedOutfits = context.watch<WardrobeProvider>().savedOutfits;
    final provider = context.read<WardrobeProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Sleek background
      appBar: AppBar(
        title: const Text(
          'My Collection',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: savedOutfits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No outfits saved yet.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate one and click "Save!"',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    // Look up the full item objects using the stored IDs
    return outfit.itemIds
        .map(
          (id) => provider.items.cast<WardrobeItem?>().firstWhere(
            (item) => item?.id == id,
            orElse: () => null,
          ),
        )
        .whereType<WardrobeItem>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: Style Name and Date ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit.style,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        outfit.event.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM d').format(outfit.dateSaved),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Description ---
          Text(
            outfit.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 20),
          Divider(height: 1, color: Colors.grey[100]),
          const SizedBox(height: 20),

          // --- Item Stack Display ---
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final bool hasImageData =
                    item.imageData != null && item.imageData!.isNotEmpty;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            WardrobeItemDetailScreen(item: item),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                      image: hasImageData
                          ? DecorationImage(
                              image: MemoryImage(item.imageData!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: hasImageData
                        ? null
                        : Center(
                            child: Icon(
                              Icons.checkroom,
                              size: 24,
                              color: Colors.grey[300],
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
