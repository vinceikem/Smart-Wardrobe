class SavedOutfit {
  final String id; // Unique ID for the saved outfit
  final String description; // Description returned from the backend
  final List<String> itemIds; // List of WardrobeItem IDs that make up the outfit
  final String style;
  final String event;
  final DateTime dateSaved;

  SavedOutfit({
    required this.id,
    required this.description,
    required this.itemIds,
    required this.style,
    required this.event,
    required this.dateSaved,
  });
}