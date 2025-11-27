// Categories for wardrobe items
enum Category {
  top('Top'),
  bottom('Bottom'),
  shoe('Shoe');
  //accessory('Accessory');

  final String display;
  const Category(this.display);
}

// Model for a single wardrobe item, using Color for simple UI visualization
