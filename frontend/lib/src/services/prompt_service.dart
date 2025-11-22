import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

// -------------------------------------------------------------------
// 1. DATA MODEL FOR UPLOADED IMAGES
// -------------------------------------------------------------------

/// Holds the File object (from the temporary cache path) and its original name
class ImageUploadData {
  final File file;
  final String originalFilename;

  ImageUploadData(this.file, this.originalFilename);
}

// -------------------------------------------------------------------
// 2. PROMPT SERVICE CLASS
// -------------------------------------------------------------------

class PromptService {
  // Use a private static Dio instance for better resource management
  static final Dio _dio = Dio();

  // CRITICAL FIX: The API endpoint must include the http:// or https:// scheme
  final String apiEndpoint = "http://10.188.85.143:3000/v1/api/prompt";
  
  // NOTE: REMOVED the constructor and internal fields (images, event, style, weather)

  /// Converts ImageUploadData objects into a List of MultipartFile objects.
  Future<List<MultipartFile>> _filesToUpload(List<ImageUploadData> images) async {
    List<MultipartFile> result = [];

    for (ImageUploadData data in images) {
      // 1. Look up MIME type using the temporary file path
      String? mimeStr = lookupMimeType(data.file.path);
      MediaType contentType = MediaType.parse(mimeStr ?? 'image/jpeg');

      // 2. Create the MultipartFile
      result.add(
        await MultipartFile.fromFile(
          data.file.path, 
          filename: data.originalFilename, 
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
    var formData = FormData.fromMap({
      // Text fields
      'event': event,
      'style': style,
      'weather': weather,

      // The file list. Key must match the backend's expected array field name.
      'wardrobe': await _filesToUpload(uploadImages), // Pass the list here
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
      return response.data is Map
          ? response.data
          : {"success": true, "data": response.data};
    } on DioException catch (e) {
      print('❌ Upload Failed!');
      print('Error: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
      }
      return {"success": false, "error": e.message};
    }
  }
}