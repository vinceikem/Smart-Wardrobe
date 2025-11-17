import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/src/services/prompt_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

final List<ImageUploadData> _selectedImages = [];

class HorizontalImagePicker extends StatefulWidget {
  const HorizontalImagePicker({super.key});

  @override
  State<HorizontalImagePicker> createState() => _HorizontalImagePickerState();
}

class _HorizontalImagePickerState extends State<HorizontalImagePicker> {
  // List to hold the selected files (capped at 10)

  final int maxImages = 10;
  final ImagePicker _picker = ImagePicker();


  Future<void> _pickImages() async {
    int remaining = maxImages - _selectedImages.length;

    if (remaining > 0) {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles != null) {
        setState(() {
          for (var xfile in pickedFiles) {
            if (_selectedImages.length < maxImages) {
              String extension = p.extension(xfile.path);

              String uniqueName =
                  'upload_img_${_selectedImages.length + 1}$extension';

              print('Reconstructed Filename: $uniqueName');

              _selectedImages.add(
                ImageUploadData(
                  File(xfile.path),
                  uniqueName,
                ),
              );
            } else {
              break;
            }
          }
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum of $maxImages images reached!')),
        );
      }
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Add Button (shows only if cap hasn't been reached)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _selectedImages.length < maxImages ? _pickImages : null,
            icon: const Icon(Icons.add_a_photo),
            label: Text(
              _selectedImages.length < maxImages
                  ? 'Add Image (${_selectedImages.length}/$maxImages)'
                  : 'Limit Reached ($maxImages)',
            ),
          ),
        ),

        // 2. The Horizontal Scrolling List
        SizedBox(
          height: 100, // Fixed height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              final imageFile = _selectedImages[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Image thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        imageFile.file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Remove button
                    GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            HorizontalImagePicker(),
            ElevatedButton(
              onPressed: () async {
                PromptService promptService = PromptService(
                  _selectedImages,
                  "",
                  "sports",
                  "",
                );
                final response = await promptService.send();
                print(response);
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
