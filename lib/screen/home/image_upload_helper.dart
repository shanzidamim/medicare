import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'package:flutter/foundation.dart';

final ImagePicker _picker = ImagePicker();
final ApiService _api = ApiService();

Future<Map<String, dynamic>?> pickAndUploadImage(
    int id,
    File image,
    bool isDoctor,
    ) async {
  try {
    if (isDoctor) {
      final result = await _api.uploadDoctorImage(id, image.path);

      if (result['status'] == true) {
        debugPrint("✔ Doctor image uploaded: ${result['image_url']}");
        return result;   // return MAP
      } else {
        debugPrint(" Doctor upload failed: ${result['message']}");
        return null;
      }
    } else {
      final result = await _api.uploadShopImage(id, image.path);

      if (result['status'] == true) {
        debugPrint("✔ Shop image uploaded: $result");
        return result;   // return MAP
      } else {
        debugPrint("Shop upload failed: ${result['message']}");
        return null;
      }
    }
  } catch (e) {
    debugPrint(" Upload error: $e");
    return null;
  }
}

