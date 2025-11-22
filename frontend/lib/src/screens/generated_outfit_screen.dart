// 1. GeneratedOutfitScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/wardrobe_item_2.dart'; // Category enum
import '../models/wardrobe_item.dart' as WardrobeItemModel; // Hive Wardrobe Item
import '../models/saved_outfit.dart'; // Hive Saved Outfit
import '../providers/wardrobe_provider.dart';
import 'package:frontend/src/services/prompt_service.dart'; // Used for ImageUploadData

class GeneratedOutfitScreen extends StatefulWidget {
  final List<ImageUploadData> uploadData;
  final String style;
  final String event;
  final String weather;
  // NOTE: Assuming your PromptService returns the generated image URL
  final String generatedImageUrl = 'https://picsum.photos/400/600'; // MOCK URL

  const GeneratedOutfitScreen({
    super.key,
    required this.uploadData,
    required this.style,
    required this.event,
    required this.weather,
  });

  @override
  State<GeneratedOutfitScreen> createState() => _GeneratedOutfitScreenState();
}

class _GeneratedOutfitScreenState extends State<GeneratedOutfitScreen> {
  // Mock results for Outfit Generation until user provides the service class
  Future<Map<Category, String>> _mockOutfitFuture() async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate finding mock IDs. NOTE: These IDs must exist in your WardrobeProvider's _items list!
    return {
      Category.top: '1', 
      Category.bottom: '2', 
      Category.shoe: '3',
    };
  }

  Future<String> _mockDescriptionFuture() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'This is a mock analysis! The backend suggests a **${widget.style}** outfit for a **${widget.event}**. Integrate your service class to get real results!';
  }
  
  late Future<List<dynamic>> _outfitResultsFuture;
  Map<Category, WardrobeItemModel.WardrobeItem?> _generatedItems = {}; // Use Hive Model
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _outfitResultsFuture = Future.wait([_mockOutfitFuture(), _mockDescriptionFuture()]); 
  }

  void _saveOutfit(String description, List<String> itemIds) async {
    if (_isSaving) return;
    setState(() { _isSaving = true; });

    // The new SavedOutfit model requires imageUrl
    final newSavedOutfit = SavedOutfit(
      id: const Uuid().v4(),
      description: description,
      itemIds: itemIds,
      style: widget.style,
      event: widget.event,
      dateSaved: DateTime.now(),
      imageUrl: widget.generatedImageUrl, // <--- Use the generated URL
    );

    Provider.of<WardrobeProvider>(context, listen: false).saveOutfit(newSavedOutfit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit saved successfully!')),
    );
    
    // Optionally pop the screen after saving
    Navigator.of(context).pop(); 
    
    setState(() { _isSaving = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Outfit'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _outfitResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final generatedItemIds = snapshot.data![0] as Map<Category, String>;
            final description = snapshot.data![1] as String;
            
            final provider = context.read<WardrobeProvider>();
            
            // Map the Category enum to the Hive model instance
            final itemsMap = generatedItemIds.map(
              (key, value) => MapEntry(key, provider.items.cast<WardrobeItemModel.WardrobeItem?>().firstWhere(
                (item) => item?.id == value, 
                orElse: () => null // Handle item not found
              )),
            );
            
            _generatedItems = Map<Category, WardrobeItemModel.WardrobeItem?>.from(itemsMap.cast());
            final itemIdsList = generatedItemIds.values.toList();


            return _buildOutfitDisplay(description, itemIdsList);
          }
          return const SizedBox.shrink(); 
        },
      ),
    );
  }

  Widget _buildOutfitDisplay(String description, List<String> itemIdsList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGeneratedImage(), // New Widget for the main image
          const SizedBox(height: 24),
          _buildItemStack(),
          const SizedBox(height: 24),
          _buildAnalysisCard(description),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : () => _saveOutfit(description, itemIdsList),
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.favorite),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(_isSaving ? 'Saving...' : 'Save This Outfit', style: const TextStyle(fontSize: 18)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedImage() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.generatedImageUrl,
          height: 300,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 300,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }


  Widget _buildItemStack() {
    final List<Widget> itemWidgets = [];
    final orderedCategories = [Category.top, Category.bottom, Category.shoe];
    
    for (var cat in orderedCategories) {
      final item = _generatedItems[cat];
      if (item != null) {
        itemWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Container(
              width: 100, // Fixed width for horizontal stack
              height: 120,
              decoration: BoxDecoration(
                // CRITICAL CHANGE: Use image path instead of color
                image: item.imagePath != null && File(item.imagePath).existsSync()
                    ? DecorationImage(
                        image: FileImage(File(item.imagePath)),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey.shade300, // Fallback color
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                   if (item.imagePath == null || !File(item.imagePath).existsSync())
                       Center(child: Icon(Icons.checkroom, color: Colors.grey.shade600, size: 48)),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Text(
                      item.category, // Display the string category
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    // Change to horizontal view to save space and display items side-by-side
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: itemWidgets,
      ),
    );
  }

  Widget _buildAnalysisCard(String description) {
    // ... (No major change, uses same logic)
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Style Analysis (Mock)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const Divider(),
            Text('Style: ${widget.style}'),
            Text('Event: ${widget.event}'),
            const SizedBox(height: 12),
            Text(description),
          ],
        ),
      ),
    );
  }
}