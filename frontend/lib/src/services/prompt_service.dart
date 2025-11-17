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

  // Use the new custom list of image data
  List<ImageUploadData> images;
  String? event;
  String? style;
  String? weather;

  // Constructor
  PromptService(this.images, this.event, this.style, this.weather);

  /// Converts ImageUploadData objects into a List of MultipartFile objects.
  /// Returns a non-nullable list.
  Future<List<MultipartFile>> _filesToUpload() async {
    List<MultipartFile> result = [];

    for (ImageUploadData data in images) {
      // 1. Look up MIME type using the temporary file path
      String? mimeStr = lookupMimeType(data.file.path);
      MediaType contentType = MediaType.parse(mimeStr ?? 'image/jpeg');

      // 2. Create the MultipartFile
      result.add(
        await MultipartFile.fromFile(
          data.file.path, // Use the temporary path for the file content
          filename:
              data.originalFilename, // <-- Use the stored original name here
          contentType: contentType,
        ),
      );
    }
    print(result[0].filename);
    return result;
  }

  Future<Map<String, dynamic>> send() async {
    var formData = FormData.fromMap({
      // Text fields
      'event': event,
      'style': style,
      'weather': weather,

      // The file list. Key must match the backend's expected array field name.
      'wardrobe': await _filesToUpload(),
    });

    try {
      Response response = await _dio.post(
        // Use the static dio instance
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
