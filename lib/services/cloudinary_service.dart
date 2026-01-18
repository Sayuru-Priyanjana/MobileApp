import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class CloudinaryService {
  // Signed upload
  Future<String?> uploadMedia(
    File file, {
    String resourceType = 'image',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // key=value&timestamp=...
      final paramsToSign =
          'timestamp=$timestamp${AppConstants.cloudinaryApiSecret}';
      final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['api_key'] = AppConstants.cloudinaryApiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final json = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return json['secure_url'];
      } else {
        print('Cloudinary Error: ${json['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }
}
