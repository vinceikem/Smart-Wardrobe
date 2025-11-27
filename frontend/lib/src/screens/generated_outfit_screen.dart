import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import '../models/wardrobe_item_2.dart'; // Category enum
import '../models/wardrobe_item.dart'; // Hive Wardrobe Item
import '../models/saved_outfit.dart'; // Hive Saved Outfit
import '../providers/wardrobe_provider.dart';
import 'package:frontend/src/services/prompt_service.dart';
import '../models/image_upload_data.dart';

class GeneratedOutfitScreen extends StatefulWidget {
  final List<ImageUploadData> uploadData;
  final String style;
  final String event;
  final String weather;

  final String generatedImageUrl = '';

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
  bool _isSaving = false;

  late Future<Map<String, dynamic>> _outfitResultFuture;

  Map<Category, WardrobeItem?> _generatedItems = {};

  @override
  void initState() {
    super.initState();
    _outfitResultFuture = _callOutfitService();
  }

  // --- Core Service Call Logic (Placeholder) ---
  Future<Map<String, dynamic>> _callOutfitService() async {
    final service = PromptService();

    // Simulating API call delay for demonstration
    await Future.delayed(const Duration(seconds: 2));

    final response = await service.send(
      uploadImages: widget.uploadData,
      style: widget.style,
      event: widget.event,
      weather: widget.weather,
    );

    if (response['success'] == true && response['data'] is Map) {
      final responseData = response['data'] as Map<String, dynamic>;

      final Map<String, String> itemIds = {};
      String? description;

      responseData.forEach((key, value) {
        if (key == 'response' && value is String) {
          description = value;
        } else if (value is String) {
          itemIds[key] = value;
        }
      });

      if (description == null || itemIds.isEmpty) {
        // Fallback mock data
        return {
          'items': {'top': 'example-top-id', 'bottom': 'example-bottom-id'},
          'description': 'Placeholder outfit analysis from service.',
        };
      }

      return {'items': itemIds, 'description': description};
    } else {
      // Fallback mock data on service failure
      return {
        'items': {'top': 'example-top-id', 'bottom': 'example-bottom-id'},
        'description': 'Placeholder outfit analysis (Service call failed).',
      };
    }
  }

  // --- Outfit Save Logic ---
  void _saveOutfit(String description, List<String> itemIds) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    final newSavedOutfit = SavedOutfit(
      id: const Uuid().v4(),
      description: description,
      itemIds: itemIds,
      style: widget.style,
      event: widget.event,
      dateSaved: DateTime.now(),
      imageUrl: widget.generatedImageUrl,
    );

    // Mocking the save call
    await Future.delayed(const Duration(milliseconds: 500));

    Provider.of<WardrobeProvider>(
      context,
      listen: false,
    ).saveOutfit(newSavedOutfit);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved successfully!')),
      );

      Navigator.of(context).pop();
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Generated Outfit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pinkAccent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _outfitResultFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.pinkAccent),
                  SizedBox(height: 16),
                  Text(
                    'Generating the perfect outfit...',
                    style: TextStyle(color: Colors.pinkAccent, fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Service Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final generatedItemIdsMap =
                snapshot.data!['items'] as Map<String, String>;
            final description = snapshot.data!['description'] as String;

            final itemIdsList = generatedItemIdsMap.values.toList();
            final provider = context.read<WardrobeProvider>();

            _generatedItems = {};
            generatedItemIdsMap.forEach((key, itemId) {
              final category = Category.values.firstWhere(
                (e) => e.toString().split('.').last == key,
                
              );

              final item = provider.items.cast<WardrobeItem?>().firstWhere(
                (i) => i?.id == itemId,
                orElse: () => null,
              );
              _generatedItems[category] = item;
            });

            return _buildOutfitDisplay(description, itemIdsList);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- Display Widgets ---

  Widget _buildOutfitDisplay(String description, List<String> itemIdsList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0), // Extra space at bottom
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Individual Item Cards (Horizontal Scroll)
          const Padding(
            // Adjusted top padding to look clean at the top of the scroll view
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Selected Items from Your Wardrobe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildItemStack(),

          // 2. Analysis Card
          const SizedBox(height: 24),
          _buildAnalysisCard(description),

          // 3. Save Button
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _isSaving
                  ? null
                  : () => _saveOutfit(description, itemIdsList),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.favorite),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  _isSaving ? 'Saving...' : 'Save This Outfit',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Item Stack Widget (Displays local images horizontally with increased size) ---
  Widget _buildItemStack() {
    final List<Widget> itemWidgets = [];
    final orderedCategories = [
      Category.top,
      Category.bottom,
      Category.shoe,
    ];

    final recommendedItems = orderedCategories
        .map((cat) => _generatedItems[cat])
        .where((item) => item != null)
        .cast<WardrobeItem>()
        .toList();

    for (var item in recommendedItems) {
      final Uint8List? imageData = item.imageData;
      final hasImage = imageData != null && imageData.isNotEmpty;
      final categoryString = item.category.toString().split('.').last;

      itemWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  image: hasImage
                      ? DecorationImage(
                          image: MemoryImage(imageData),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: hasImage ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink.shade100, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: !hasImage
                    ? Center(
                        child: Icon(
                          Icons.checkroom,
                          color: Colors.pinkAccent.withOpacity(0.6),
                          size: 36,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                categoryString.substring(0, 1).toUpperCase() +
                    categoryString.substring(1),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (itemWidgets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            "No recommended items found in your wardrobe for this request.",
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: itemWidgets),
    );
  }

  // --- Analysis Card Widget ---
  Widget _buildAnalysisCard(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Style Analysis',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const Divider(color: Colors.pinkAccent, height: 20),

              _buildDetailRow(
                Icons.color_lens,
                'Style',
                widget.style,
                Colors.pink,
              ),
              _buildDetailRow(Icons.event, 'Event', widget.event, Colors.teal),
              _buildDetailRow(
                Icons.cloud,
                'Weather',
                widget.weather,
                Colors.blue,
              ),

              const SizedBox(height: 16),

              const Text(
                'Recommendation Rationale:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                description,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
