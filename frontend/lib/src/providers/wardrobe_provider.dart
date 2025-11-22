import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/wardrobe_item_2.dart'; // For Category enum
import '../models/wardrobe_item.dart';
import '../models/saved_outfit.dart'; // <-- NEW: Import for SavedOutfit model

class WardrobeProvider with ChangeNotifier {
  // --- Wardrobe Item State (Existing) ---
  List<WardrobeItem> _items = [];
  late Box<WardrobeItem> _wardrobeBox;
  final String _wardrobeBoxName = 'wardrobeBox';
  
  // --- Saved Outfit State (NEW) ---
  List<SavedOutfit> _savedOutfits = [];
  late Box<SavedOutfit> _savedOutfitsBox;
  final String _outfitBoxName = 'savedOutfitsBox';

  bool _isInitialized = false; 

  WardrobeProvider() {
    _initializeHive();
  }

  // --- Public Getters ---
  List<WardrobeItem> get items => _items;
  List<SavedOutfit> get savedOutfits => _savedOutfits; // <-- NEW: Getter for saved outfits
  bool get isInitialized => _isInitialized; 

  // --- Persistence Initialization ---
  void _initializeHive() async {
    try {
      // 1. Initialize Wardrobe Box
      if (!Hive.isBoxOpen(_wardrobeBoxName)) {
        _wardrobeBox = await Hive.openBox<WardrobeItem>(_wardrobeBoxName);
      } else {
        _wardrobeBox = Hive.box<WardrobeItem>(_wardrobeBoxName);
      }
      
      // 2. Initialize Saved Outfit Box (NEW)
      if (!Hive.isBoxOpen(_outfitBoxName)) {
        _savedOutfitsBox = await Hive.openBox<SavedOutfit>(_outfitBoxName);
      } else {
        _savedOutfitsBox = Hive.box<SavedOutfit>(_outfitBoxName);
      }
      
      // Load existing items from both boxes
      _items = _wardrobeBox.values.toList();
      _savedOutfits = _savedOutfitsBox.values.toList(); // <-- Load saved outfits
      
      _isInitialized = true;
      debugPrint('Hive Boxes initialized successfully. Loaded ${_items.length} items and ${_savedOutfits.length} outfits.');
      
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      _isInitialized = true; 
    } finally {
      notifyListeners();
    }
  }

  // --- Add Item Method (WardrobeItem) ---
  void addItem(Category category, Uint8List imageData) async {
    if (!_isInitialized) {
      debugPrint('Warning: Hive not initialized. Skipping save operation.');
      return; 
    }

    final newItem = WardrobeItem(
      id: UniqueKey().toString(),
      category: category.name,
      imageData: imageData,
      createdAt: DateTime.now(),
    );

    try {
      await _wardrobeBox.add(newItem);
      _items = _wardrobeBox.values.toList();
      debugPrint('Item added successfully. Total items in wardrobe: ${_items.length}');
    } catch (e) {
      debugPrint('Error adding item to Hive: $e');
    }

    notifyListeners();
  }
  
  // --- Save Outfit Method (NEW) ---
  void saveOutfit(SavedOutfit outfit) async {
     if (!_isInitialized) {
      debugPrint('Warning: Hive not initialized. Skipping outfit save operation.');
      return; 
    }
    
    try {
      // 1. Add to the SavedOutfits Hive box
      await _savedOutfitsBox.add(outfit);
      
      // 2. Refresh the in-memory list
      _savedOutfits = _savedOutfitsBox.values.toList();
      debugPrint('Outfit saved successfully. Total saved outfits: ${_savedOutfits.length}');
    } catch (e) {
      debugPrint('Error saving outfit to Hive: $e');
    }
    
    notifyListeners();
  }

  // --- Delete Item Method (WardrobeItem) ---
  void deleteItem(String id) async {
    if (!_isInitialized) return;
    
    // Find the item within the *live* list which should be a HiveObject
    final itemToDelete = _items.firstWhere((item) => item.id == id, 
      orElse: () => null as WardrobeItem
    );

    if (itemToDelete != null) {
      try {
        await itemToDelete.delete(); 
        debugPrint('Item with ID $id deleted successfully.');
        
        // Refresh the in-memory list
        _items.removeWhere((item) => item.id == id);
      } catch (e) {
        debugPrint('Error deleting item from Hive: $e');
      }
    }

    notifyListeners();
  }
}