import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/image_upload_data.dart';

class PromptService {
  // Use a private static Dio instance for better resource management
  static final Dio _dio = Dio();

  // CRITICAL FIX: The API endpoint must include the http:// or https:// scheme
  final String apiEndpoint = "${dotenv.env['API_URI']}/v1/api/prompt";

  /// Converts ImageUploadData objects (now containing Uint8List data)
  /// into a List of MultipartFile objects using fromBytes.
  Future<List<MultipartFile>> _filesToUpload(
    List<ImageUploadData> images,
  ) async {
    List<MultipartFile> result = [];

    for (ImageUploadData data in images) {
      // 1. Check for persistent image data
      if (data.imageData == null || data.imageData!.isEmpty) {
        print(
          'Warning: Skipping item with missing image data: ${data.category}',
        );
        continue;
      }

      // CRITICAL FIX: Ensure the ID is present for the required filename format
      // We assume ImageUploadData has an 'id' field for this to work.
      // Format: category-id.jpeg
      if (data.id.isEmpty) {
        print(
          'Warning: Skipping item because ID is missing for filename generation: ${data.category}',
        );
        continue;
      }

      // 2. Construct the filename as category-id.jpeg as required by the backend
      String filename = '${data.category}-${data.id}';

      // We cannot reliably determine MIME type from bytes, so we assume jpeg
      String? mimeStr = lookupMimeType(
        filename,
      ); // Fallback lookup by extension
      MediaType contentType = MediaType.parse(mimeStr ?? 'image/jpeg');

      // 3. Create the MultipartFile using the BYTES
      result.add(
        MultipartFile.fromBytes(
          data.imageData!, // Use the actual Uint8List data
          filename: filename, // Use the category-id filename
          contentType: contentType,
        ),
      );
    }
    return result;
  }

  // CRITICAL CHANGE: Send now accepts all parameters directly
  Future<Map<String, dynamic>> send({
    required List<ImageUploadData> uploadImages,
    required String? event,
    required String? style,
    required String? weather,
  }) async {
    // Check if files were successfully converted to MultipartFile objects
    final files = await _filesToUpload(uploadImages);

    if (files.isEmpty) {
      return {
        "success": false,
        "error": "No valid image data was found for upload.",
      };
    }

    var formData = FormData.fromMap({
      // Text fields
      'event': event,
      'style': style,
      'weather': weather,

      // The file list. Key must match the backend's expected array field name ('wardrobe').
      'wardrobe': files, // Use the prepared files list
    });

    try {
      Response response = await _dio.post(
        apiEndpoint,
        data: formData,
        onSendProgress: (sent, total) {
          if (total != 0) {
            print(
              'Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );
      print('✅ Upload Successful. Response Status: ${response.statusCode}');
      print(response.data);
      return response.data is Map
          ? response.data
          : {"success": true, "data": response.data};
    } on DioException catch (e) {
      print('❌ Upload Failed!');
      print('Error: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        // Optional: return backend error message if available
        if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          return {"success": false, "error": e.response!.data['message']};
        }
      }
      return {"success": false, "error": e.message};
    }
  }
}
