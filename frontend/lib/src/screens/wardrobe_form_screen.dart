import 'dart:io'; // Needed for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // New dependency
import 'package:provider/provider.dart';
import '../models/wardrobe_item_2.dart'; // Assuming this has the Category enum
import '../providers/wardrobe_provider.dart';

class WardrobeFormScreen extends StatefulWidget {
  const WardrobeFormScreen({super.key});

  @override
  State<WardrobeFormScreen> createState() => _WardrobeFormScreenState();
}

class _WardrobeFormScreenState extends State<WardrobeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Category _selectedCategory = Category.top;
  XFile? _pickedImage; // State to hold the picked image file data
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // Optimize image size for storage
    );

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_pickedImage == null) {
        // Show error if no image is picked
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image for your item.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Use the Provider to add the new item
      Provider.of<WardrobeProvider>(context, listen: false).addItem(
        _selectedCategory,
        _pickedImage!.path, // Pass the image path to the provider
      );

      // Reset form fields
      setState(() {
        _selectedCategory = Category.top;
        _pickedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedCategory.display} item added successfully!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Wardrobe Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Image Picker Widget ---
              _ImageInputContainer(
                pickedImage: _pickedImage,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: 24),

              // --- Category Selection (No change) ---
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                value: _selectedCategory,
                items: Category.values.map((Category cat) {
                  return DropdownMenuItem<Category>(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(cat), color: Colors.teal),
                        const SizedBox(width: 10),
                        Text(cat.display),
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
              const SizedBox(height: 32),

              // --- Submit Button (No change) ---
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Add Item to Wardrobe', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extracted widget for better readability
  IconData _getCategoryIcon(Category cat) {
    switch (cat) {
      case Category.top:
        return Icons.add; // Changed from Icons.add to a more shirt-like icon for clarity
      case Category.bottom:
        return Icons.straighten;
      case Category.shoe:
        return Icons.checkroom; // Changed from Icons.settings
      case Category.accessory:
        return Icons.watch;
    }
  }

  // No need for dispose since _colorController is removed
}

// Extracted the Image/Color Container into a separate widget for clarity
class _ImageInputContainer extends StatelessWidget {
  const _ImageInputContainer({
    required this.pickedImage,
    required this.onPickImage,
  });

  final XFile? pickedImage;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade300, width: 2),
              image: pickedImage != null
                  ? DecorationImage(
                      image: FileImage(File(pickedImage!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: pickedImage == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.teal,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to Pick Image',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }
}