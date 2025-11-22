import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../models/wardrobe_item_2.dart';
import '../providers/wardrobe_provider.dart';

class WardrobeFormScreen extends StatefulWidget {
  const WardrobeFormScreen({super.key});

  @override
  State<WardrobeFormScreen> createState() => _WardrobeFormScreenState();
}

class _WardrobeFormScreenState extends State<WardrobeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Category _selectedCategory = Category.top;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for your item.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing image...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final Uint8List imageData = await _pickedImage!.readAsBytes();

    Provider.of<WardrobeProvider>(
      context,
      listen: false,
    ).addItem(_selectedCategory, imageData);

    setState(() {
      _selectedCategory = Category.top;
      _pickedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedCategory.display} added to wardrobe!'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Sleek background
      appBar: AppBar(
        title: const Text(
          'Add New Item',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSectionHeader('Item Image', Icons.camera_alt_outlined),
              const SizedBox(height: 12),
              _ImageInputContainer(
                pickedImage: _pickedImage,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: 32),

              _buildSectionHeader('Category', Icons.category_outlined),
              const SizedBox(height: 12),
              _buildSleekDropdown(),

              const SizedBox(height: 48),

              // Submit Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Add to Wardrobe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0, // Shadow handled by Container
                  ),
                ),
              ),
            ],
          ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildSleekDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<Category>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.label_outline, color: Colors.grey),
        ),
        value: _selectedCategory,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.pinkAccent),
        items: Category.values.map((Category cat) {
          return DropdownMenuItem<Category>(
            value: cat,
            child: Row(
              children: [
                // Small color-coded icon for the category
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(cat),
                    color: Colors.pinkAccent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  cat.display,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (Category? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedCategory = newValue;
            });
          }
        },
      ),
    );
  }

  IconData _getCategoryIcon(Category cat) {
    switch (cat) {
      case Category.top:
        return Icons.checkroom;
      case Category.bottom:
        return Icons.straighten;
      case Category.shoe:
        return Icons.do_not_step;
      case Category.accessory:
        return Icons.watch;
    }
  }
}

class _ImageInputContainer extends StatelessWidget {
  const _ImageInputContainer({
    required this.pickedImage,
    required this.onPickImage,
  });

  final XFile? pickedImage;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;

    if (pickedImage != null) {
      imageWidget = FutureBuilder<Uint8List>(
        key: ValueKey(pickedImage!.path),
        future: pickedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250, // Taller image preview
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          );
        },
      );
    }

    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        height: 250,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: pickedImage == null
              ? Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ) // Dashed border simulation (solid for simplicity here)
              : null,
        ),
        child:
            imageWidget ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    color: Colors.pinkAccent.withOpacity(0.7),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap to Upload Image',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
