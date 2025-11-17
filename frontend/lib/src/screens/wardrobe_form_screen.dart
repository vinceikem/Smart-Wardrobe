import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';

class WardrobeFormScreen extends StatefulWidget {
  const WardrobeFormScreen({super.key});

  @override
  State<WardrobeFormScreen> createState() => _WardrobeFormScreenState();
}

class _WardrobeFormScreenState extends State<WardrobeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Category _selectedCategory = Category.top;
  final TextEditingController _colorController = TextEditingController(text: '00796B');
  Color _currentColor = Colors.teal;

  void _updateColor(String hex) {
    try {
      final colorValue = int.parse(hex, radix: 16);
      setState(() {
        _currentColor = Color(0xFF000000 + colorValue);
      });
    } catch (e) {
      setState(() {
        _currentColor = Colors.teal;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Use the Provider to add the new item
      Provider.of<WardrobeProvider>(context, listen: false).addItem(
        _selectedCategory,
        _currentColor,
      );

      // Reset form fields
      _colorController.text = '00796B';
      _updateColor(_colorController.text);
      setState(() {
        _selectedCategory = Category.top;
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
              // --- Image/Color Picker (Simulated Image Input) ---
              const Text(
                'Simulated Image Input',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade300, width: 2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.white70,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to "Pick Image" (Color: #${_colorController.text})',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // --- Hex Color Input Field (Simulating Image Path/Data) ---
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Item Color (Hex Code - RRGGBB)',
                  hintText: 'e.g., FF0000 for Red',
                  prefixIcon: Icon(Icons.palette, color: _currentColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: _updateColor,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 6) {
                    return 'Please enter a valid 6-digit hex code (RRGGBB).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Category Selection ---
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

              // --- Submit Button ---
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

  IconData _getCategoryIcon(Category cat) {
    switch (cat) {
      case Category.top:
        return Icons.add;
      case Category.bottom:
        return Icons.straighten;
      case Category.shoe:
        return Icons.settings;
      case Category.accessory:
        return Icons.watch;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }
}