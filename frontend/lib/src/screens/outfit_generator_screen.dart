import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../models/image_upload_data.dart';
import '../models/wardrobe_item_2.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';
import 'generated_outfit_screen.dart';

class OutfitGeneratorScreen extends StatefulWidget {
  const OutfitGeneratorScreen({super.key});

  @override
  State<OutfitGeneratorScreen> createState() => _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState extends State<OutfitGeneratorScreen> {
  // --- Business Logic State (Unchanged) ---
  final Map<Category, List<String>> _selectedItemIds = {
    Category.top: [],
    Category.bottom: [],
    Category.shoe: [],
  };

  String _style = 'Casual';
  String _event = 'Everyday';
  String _weather = 'Sunny';

  // --- Business Logic Methods (Unchanged) ---
  void _toggleSelection(Category category, String itemId) {
    setState(() {
      final list = _selectedItemIds[category]!;
      if (list.contains(itemId)) {
        list.remove(itemId);
      } else if (list.length < 3) {
        list.add(itemId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 3 items per category selected.'),
            behavior: SnackBarBehavior.floating,
          ),
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
        const SnackBar(
          content: Text(
            'Please select at least one item to generate an outfit.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    for (var id in allSelectedIds) {
      // Logic relies on Hive persistence (Uint8List)
      final item = provider.items.firstWhere((i) => i.id == id);

      uploadData.add(
        ImageUploadData(
          id: item.id,
          imageData: item.imageData,
          category: item.category,
        ),
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GeneratedOutfitScreen(
          uploadData: uploadData,
          style: _style,
          event: _event,
          weather: _weather,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WardrobeProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Softer background
      // Sleek transparent AppBar
      appBar: AppBar(
        title: const Text(
          'Curate Your Look',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSectionHeader('Wardrobe Selection', Icons.checkroom),
                  const SizedBox(height: 10),

                  // Category Selectors
                  ..._buildCategorySelectors(provider),

                  const SizedBox(height: 30),
                  _buildSectionHeader('The Occasion', Icons.event_note),
                  const SizedBox(height: 15),

                  // Context Inputs
                  _buildConfigurationInputs(),
                ],
              ),
            ),

            // Floating Bottom Action Button
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _generateOutfit(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0, // Shadow handled by Container
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 12),
                      Text(
                        'Generate Outfit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.pinkAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 1.0,
            // uppercase: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategorySelectors(WardrobeProvider provider) {
    return [
      for (var category in [Category.top, Category.bottom, Category.shoe])
        Consumer<WardrobeProvider>(
          builder: (context, p, child) {
            final items = p.items
                .where((i) => i.category == category.toString().split('.').last)
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _SleekCategorySelector(
                category: category,
                items: items,
                selectedIds: _selectedItemIds[category]!,
                onToggle: _toggleSelection,
              ),
            );
          },
        ),
    ];
  }

  Widget _buildConfigurationInputs() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          _buildSleekTextField(
            label: 'Style',
            hint: 'e.g., Bohemian, Minimalist',
            icon: Icons.style,
            initialValue: _style,
            onChanged: (val) => _style = val,
          ),
          const SizedBox(height: 16),
          _buildSleekTextField(
            label: 'Event',
            hint: 'e.g., Dinner, Work, Hiking',
            icon: Icons.place,
            initialValue: _event,
            onChanged: (val) => _event = val,
          ),
          const SizedBox(height: 16),
          _buildSleekTextField(
            label: 'Weather',
            hint: 'e.g., Sunny, Rainy, Cold',
            icon: Icons.wb_sunny,
            initialValue: _weather,
            onChanged: (val) => _weather = val,
          ),
        ],
      ),
    );
  }

  Widget _buildSleekTextField({
    required String label,
    required String hint,
    required IconData icon,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.pinkAccent.withOpacity(0.7),
          size: 22,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pinkAccent, width: 1.5),
        ),
        floatingLabelStyle: const TextStyle(color: Colors.pinkAccent),
      ),
    );
  }
}

// --- New Sleek UI Components ---

class _SleekCategorySelector extends StatelessWidget {
  final Category category;
  final List<WardrobeItem> items;
  final List<String> selectedIds;
  final Function(Category, String) onToggle;

  const _SleekCategorySelector({
    required this.category,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      // Empty state
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
            const SizedBox(width: 12),
            Text(
              'No ${category.display.toLowerCase()}s available.',
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.display,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selectedIds.isNotEmpty
                      ? Colors.pinkAccent
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedIds.length}/3',
                  style: TextStyle(
                    color: selectedIds.isNotEmpty
                        ? Colors.white
                        : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140, // Height for the scrolling list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedIds.contains(item.id);
              final Uint8List? imageData = item.imageData;
              final bool hasImageData =
                  imageData != null && imageData.isNotEmpty;

              return GestureDetector(
                onTap: () => onToggle(category, item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 100,
                  margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.pinkAccent
                          : Colors.transparent,
                      width: isSelected ? 2.5 : 0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? Colors.pinkAccent.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      14,
                    ), // Slightly less than container
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image
                        if (hasImageData)
                          Image.memory(imageData, fit: BoxFit.cover)
                        else
                          Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.checkroom,
                              color: Colors.grey,
                            ),
                          ),

                        // Selection Overlay (Subtle Darkening)
                        if (isSelected)
                          Container(color: Colors.white.withOpacity(0.1)),

                        // Checkmark Badge
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.pinkAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
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
