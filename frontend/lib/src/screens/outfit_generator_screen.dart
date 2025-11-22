import 'package:flutter/material.dart';
import 'package:frontend/src/services/prompt_service.dart';
import 'package:provider/provider.dart';
import '../models/wardrobe_item_2.dart'; // Contains Category enum
import '../models/wardrobe_item.dart' as WardrobeItemModel; // Import Hive Model
import '../providers/wardrobe_provider.dart';
import 'generated_outfit_screen.dart';
import 'dart:io'; // Needed for the File object

class OutfitGeneratorScreen extends StatefulWidget {
  const OutfitGeneratorScreen({super.key});

  @override
  State<OutfitGeneratorScreen> createState() => _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState extends State<OutfitGeneratorScreen> {
  // Map of Category to selected WardrobeItem IDs (max 3 per category)
  final Map<Category, List<String>> _selectedItemIds = {
    Category.top: [],
    Category.bottom: [],
    Category.shoe: [],
  };

  String _style = 'Casual';
  String _event = 'Everyday';
  String _weather = 'Sunny';

  void _toggleSelection(Category category, String itemId) {
    setState(() {
      final list = _selectedItemIds[category]!;
      if (list.contains(itemId)) {
        list.remove(itemId);
      } else if (list.length < 3) {
        list.add(itemId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 items per category selected.')),
        );
      }
    });
  }

  void _generateOutfit(WardrobeProvider provider) {
    List<ImageUploadData> uploadData = [];
    
    final allSelectedIds = [
      ..._selectedItemIds[Category.top]!,
      ..._selectedItemIds[Category.bottom]!,
      ..._selectedItemIds[Category.shoe]!,
    ];

    if (allSelectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item.')),
      );
      return;
    }

    // 1. Prepare ImageUploadData by getting the actual file path
    for (var id in allSelectedIds) {
      // Find the item using the ID. Since provider.items is now List<WardrobeItemModel.WardrobeItem>, we use that.
      final item = provider.items.firstWhere((i) => i.id == id); 
      
      // Use the actual image path from the Hive model
      uploadData.add(ImageUploadData(
        File(item.imagePath), // <--- CRITICAL CHANGE: Use actual path
        item.id, // Use the item ID as the original filename for identification
      ));
    }

    // 2. Navigate to the generated outfit screen to handle the service call
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => GeneratedOutfitScreen(
        uploadData: uploadData,
        style: _style,
        event: _event,
        weather: _weather,
      ),
    ));
  }
  
  // Removed MockFile() since we are using the actual File path now.

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WardrobeProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Outfit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NOTE: The provider.getItemsByCategory needs to be refactored 
            // to return the Hive model type (List<WardrobeItemModel.WardrobeItem>).
            ..._buildCategorySelectors(provider), 
            const SizedBox(height: 24),
            _buildConfigurationInputs(),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _generateOutfit(provider),
              icon: const Icon(Icons.auto_fix_high),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Generate Outfit Suggestion', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method updated to accept the Hive model list.
  List<Widget> _buildCategorySelectors(WardrobeProvider provider) {
    return [
      for (var category in [Category.top, Category.bottom, Category.shoe])
        Consumer<WardrobeProvider>(
          builder: (context, p, child) {
            // CRITICAL: We rely on the provider to filter and cast the list correctly
            final items = p.items.where((i) => i.category == category.toString().split('.').last)
                .map((item) => item as WardrobeItemModel.WardrobeItem)
                .toList();
                
            return _CategorySelector(
              category: category,
              items: items,
              selectedIds: _selectedItemIds[category]!,
              onToggle: _toggleSelection,
            );
          }
        ),
    ];
  }

  Widget _buildConfigurationInputs() {
    // ... (No change)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Optional Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Style (e.g., Bohemian, Minimalist)', border: OutlineInputBorder()),
          initialValue: _style,
          onChanged: (value) => _style = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Event (e.g., Dinner, Hiking, Work)', border: OutlineInputBorder()),
          initialValue: _event,
          onChanged: (value) => _event = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Weather Condition (Required by Service)', border: OutlineInputBorder()),
          initialValue: _weather,
          onChanged: (value) => _weather = value,
        ),
      ],
    );
  }
}

// Updated to use the Hive-compatible model
class _CategorySelector extends StatelessWidget {
  final Category category;
  final List<WardrobeItemModel.WardrobeItem> items; // <-- Changed type
  final List<String> selectedIds;
  final Function(Category, String) onToggle;

  const _CategorySelector({
    required this.category,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text('No ${category.display} items in your wardrobe.', style: const TextStyle(color: Colors.red)),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            '${category.display} Items (${selectedIds.length}/3)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedIds.contains(item.id);
              
              return GestureDetector(
                onTap: () => onToggle(category, item.id),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    // CRITICAL CHANGE: Display the actual image
                    image: item.imagePath != null && File(item.imagePath).existsSync()
                        ? DecorationImage(
                            image: FileImage(File(item.imagePath)),
                            fit: BoxFit.cover,
                          )
                        : null, // Fallback to color if no image
                    color: Colors.grey.shade400, // Background color for placeholder
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.pink : Colors.transparent,
                      width: isSelected ? 3.0 : 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Display a fallback icon if image is missing
                      if (item.imagePath == null || !File(item.imagePath).existsSync())
                          Icon(
                            Icons.checkroom, 
                            color: Colors.white70,
                            size: 40
                          ),

                      Icon(
                        Icons.check_circle, 
                        color: isSelected ? Colors.pink.shade100.withOpacity(0.8) : Colors.transparent, 
                        size: 40
                      ),
                      Positioned(
                        bottom: 4,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              item.category, // Display the category string
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                            )
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}