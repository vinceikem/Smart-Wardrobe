// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../providers/wardrobe_provider.dart';
// import '../constants/categories.dart';

// class WardrobeScreen extends StatelessWidget {
//   const WardrobeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Wardrobe'),
//       ),
//       body: Consumer<WardrobeProvider>(
//         builder: (context, provider, _) {
//           if (provider.items.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.checkroom_outlined, size: 80, color: Colors.grey[300]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No items yet',
//                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Add your first clothing item',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children: WardrobeCategories.all.map((category) {
//               final items = provider.getItemsByCategory(category);
//               if (items.isEmpty) return const SizedBox.shrink();
//               return _CategorySection(category: category, items: items);
//             }).toList(),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showAddItemDialog(context),
//         backgroundColor: Colors.black,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text('Add Item', style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }

//   void _showAddItemDialog(BuildContext context) {
//     String? selectedCategory;
    
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           title: const Text('Add Wardrobe Item'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Select Category',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: WardrobeCategories.all.map((category) {
//                   final isSelected = selectedCategory == category;
//                   return ChoiceChip(
//                     label: Text(WardrobeCategories.getDisplayName(category)),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         selectedCategory = selected ? category : null;
//                       });
//                     },
//                     selectedColor: Colors.black,
//                     labelStyle: TextStyle(
//                       color: isSelected ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: selectedCategory == null
//                   ? null
//                   : () async {
//                       Navigator.pop(context);
//                       await _pickAndAddImage(context, selectedCategory!);
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Pick Image'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickAndAddImage(BuildContext context, String category) async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(source: ImageSource.gallery);
    
//     if (image != null && context.mounted) {
//       final provider = context.read<WardrobeProvider>();
//       await provider.addItem(category, File(image.path));
      
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Item added successfully')),
//         );
//       }
//     }
//   }
// }

// class _CategorySection extends StatelessWidget {
//   final String category;
//   final List items;

//   const _CategorySection({required this.category, required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Text(
//             WardrobeCategories.getDisplayName(category).toUpperCase(),
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//           ),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             final isSelected = selectedItems.contains(item);
            
//             return GestureDetector(
//               onTap: () => onItemTap(item),
//               child: Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       File(item.imagePath),
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                   ),
//                   if (isSelected)
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.black, width: 3),
//                         color: Colors.black.withOpacity(0.3),
//                       ),
//                       child: const Center(
//                         child: Icon(Icons.check_circle, color: Colors.white, size: 32),
//                       ),
//                     ),
//                   Positioned(
//                     bottom: 4,
//                     right: 4,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.7),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         item.key,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
