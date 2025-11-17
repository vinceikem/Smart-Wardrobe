import 'package:flutter/material.dart';
import 'package:frontend/src/services/prompt_service.dart';
import 'package:provider/provider.dart';
import '../models/wardrobe_item.dart';// NOTE: Requires dart:io for File
import '../providers/wardrobe_provider.dart';
import 'generated_outfit_screen.dart';
import 'dart:io'; // Needed for the mock File object

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
  String _weather = 'Sunny'; // Required by service

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
    // 1. Prepare ImageUploadData (Mock File since real file picker is not available)
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

    for (var id in allSelectedIds) {
      // Placeholder for real File object. This is where you would fetch the file path.
      uploadData.add(ImageUploadData(
        MockFile(), 
        id,
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
  
  // NOTE: This mock File implementation is strictly for making the code compile 
  // without a real environment. You must replace it with actual file handling.
  File MockFile() => File('mock_path'); 

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

  List<Widget> _buildCategorySelectors(WardrobeProvider provider) {
    return [
      for (var category in [Category.top, Category.bottom, Category.shoe])
        _CategorySelector(
          category: category,
          items: provider.getItemsByCategory(category),
          selectedIds: _selectedItemIds[category]!,
          onToggle: _toggleSelection,
        ),
    ];
  }

  Widget _buildConfigurationInputs() {
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

// Widget for item selection in the generator screen
class _CategorySelector extends StatelessWidget {
  final Category category;
  final List<WardrobeItem> items;
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
                    color: item.visualColor, // Use item color
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.pink : Colors.grey.shade300,
                      width: isSelected ? 3.0 : 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.check_circle, 
                        color: isSelected ? Colors.white : Colors.transparent, 
                        size: 40
                      ),
                      Positioned(
                        bottom: 4,
                        child: Text(
                          item.category.display, 
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
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