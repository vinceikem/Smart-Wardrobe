import 'package:flutter/material.dart';
import 'package:frontend/src/services/prompt_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/wardrobe_item.dart';
import '../models/saved_outfit.dart';
import '../providers/wardrobe_provider.dart';
// import '../services/outfit_service.dart'; // DO NOT INCLUDE - User will replace

class GeneratedOutfitScreen extends StatefulWidget {
  final List<ImageUploadData> uploadData;
  final String style;
  final String event;
  final String weather;

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
    // Simulate finding one of the mock IDs from the provider
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
  
  late Future<Map<Category, String>> _outfitFuture;
  late Future<String> _descriptionFuture;
  Map<Category, WardrobeItem> _generatedItems = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Use mock future calls until the user adds their service class
    _outfitFuture = _mockOutfitFuture(); 
    _descriptionFuture = _mockDescriptionFuture();
  }

  void _saveOutfit(String description, List<String> itemIds) async {
    if (_isSaving) return;
    setState(() { _isSaving = true; });

    final newSavedOutfit = SavedOutfit(
      id: const Uuid().v4(),
      description: description,
      itemIds: itemIds,
      style: widget.style,
      event: widget.event,
      dateSaved: DateTime.now(),
    );

    Provider.of<WardrobeProvider>(context, listen: false).saveOutfit(newSavedOutfit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit saved successfully!')),
    );
    
    setState(() { _isSaving = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Outfit'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_outfitFuture, _descriptionFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final generatedItemIds = snapshot.data![0] as Map<Category, String>;
            final description = snapshot.data![1] as String;
            
            final provider = context.read<WardrobeProvider>();
            final items = generatedItemIds.map(
              (key, value) => MapEntry(key, provider.getItemById(value)),
            );
            _generatedItems = Map<Category, WardrobeItem>.from(items.cast());
            final itemIdsList = generatedItemIds.values.toList();


            return _buildOutfitDisplay(description, itemIdsList);
          }
          return const SizedBox.shrink(); // Should not happen
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

  Widget _buildItemStack() {
    final List<Widget> itemWidgets = [];
    final orderedCategories = [Category.top, Category.bottom, Category.shoe];
    
    for (var cat in orderedCategories) {
      final item = _generatedItems[cat];
      if (item != null) {
        itemWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: item.visualColor, // Use item color
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Center(
                child: Text(
                  item.category.display,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }
    }
    return Column(children: itemWidgets);
  }

  Widget _buildAnalysisCard(String description) {
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