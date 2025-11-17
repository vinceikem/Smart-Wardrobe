import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/wardrobe_item.dart';
import '../models/saved_outfit.dart';

class WardrobeProvider extends ChangeNotifier {
  final List<WardrobeItem> _items = [];
  final List<SavedOutfit> _savedOutfits = [];
  
  List<WardrobeItem> get items => _items;
  List<SavedOutfit> get savedOutfits => _savedOutfits.reversed.toList(); 

  WardrobeProvider() {
    // Adding mock data for initial display:
    _items.addAll([
      WardrobeItem(id: '1', category: Category.top, visualColor: Colors.blueGrey),
      WardrobeItem(id: '2', category: Category.bottom, visualColor: Colors.black),
      WardrobeItem(id: '3', category: Category.shoe, visualColor: Colors.brown),
      WardrobeItem(id: '4', category: Category.top, visualColor: Colors.red.shade900),
      WardrobeItem(id: '5', category: Category.top, visualColor: Colors.green.shade700),
      WardrobeItem(id: '6', category: Category.bottom, visualColor: Colors.grey),
      WardrobeItem(id: '7', category: Category.shoe, visualColor: Colors.yellow.shade800),
      WardrobeItem(id: '8', category: Category.accessory, visualColor: Colors.orange),
    ]);
  }

  // --- Wardrobe Item Management ---

  void addItem(Category category, Color color) {
    final newItem = WardrobeItem(
      id: const Uuid().v4(),
      category: category,
      visualColor: color,
    );
    _items.add(newItem);
    // TODO: Integrate Hive save logic here
    notifyListeners();
  }

  List<WardrobeItem> getItemsByCategory(Category category) {
    return _items.where((item) => item.category == category).toList();
  }
  
  WardrobeItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- Saved Outfit Management ---

  void saveOutfit(SavedOutfit outfit) {
    _savedOutfits.add(outfit);
    // TODO: Integrate Hive save logic here
    notifyListeners();
  }
}