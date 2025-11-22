import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
// Contains Category enum
import '../models/wardrobe_item_2.dart'; 
// Alias for the new Hive model
import '../models/wardrobe_item.dart' as HiveItem; 
import '../models/saved_outfit.dart';

class WardrobeProvider extends ChangeNotifier {
  // CRITICAL CHANGE: The list now holds the Hive model type
  final List<HiveItem.WardrobeItem> _items = [];
  final List<SavedOutfit> _savedOutfits = [];
  
  // Update the getter type to reflect the Hive model
  List<HiveItem.WardrobeItem> get items => _items; 
  List<SavedOutfit> get savedOutfits => _savedOutfits.reversed.toList(); 

  WardrobeProvider() {
    // Mock data has been removed.
    // Future step: Load initial data from Hive here.
  }

  // --- Wardrobe Item Management ---

  // Refactored to accept imagePath (String) instead of Color
  void addItem(Category category, String imagePath) {
    
    // 1. Create the new Hive-compatible model instance
    final newHiveItem = HiveItem.WardrobeItem(
      id: const Uuid().v4(),
      // Store category as a string identifier
      category: category.toString().split('.').last, 
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
    
    // 2. Add to internal list for immediate UI update
    _items.add(newHiveItem);

    // TODO: Integrate Hive save logic here
    // Example: Hive.box<HiveItem.WardrobeItem>('wardrobe').put(newHiveItem.key, newHiveItem);

    notifyListeners();
  }

  // NOTE: These methods still use the old WardrobeItem type in their signature, 
  // which will require casting or a conversion/view model during full migration.
  List<WardrobeItem> getItemsByCategory(Category category) {
    // This filter logic is simplified because the provider's list changed type.
    // It should be refactored to filter based on item.category (which is now a String)
    // and then convert the result back to WardrobeItem (or change the return type).
    return []; // Returning empty list temporarily until full migration is complete.
  }
  
  WardrobeItem? getItemById(String id) {
    // This method is also currently broken due to the model type change.
    return null;
  }

  // --- Saved Outfit Management ---

  void saveOutfit(SavedOutfit outfit) {
    _savedOutfits.add(outfit);
    // TODO: Integrate Hive save logic here
    notifyListeners();
  }
}