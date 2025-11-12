import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'package:flutter/foundation.dart';

final ImagePicker _picker = ImagePicker();
final ApiService _api = ApiService();

/// Uploads an image for doctor or shop profile.
/// Returns uploaded image URL if successful, otherwise null.
Future<String?> pickAndUploadImage({
  required bool isDoctor,
  required int id,
}) async {
  try {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    debugPrint("Uploading ${image.path} ...");

    if (isDoctor) {
      final result = await _api.uploadDoctorImage(id, image.path);
      if (result['status'] == true) {
        debugPrint("✅ Doctor image uploaded: ${result['image_url']}");
        return result['image_url'];
      } else {
        debugPrint("❌ Doctor upload failed: ${result['message']}");
        return null;
      }
    } else {
      final result = await _api.uploadShopImage(id, image.path);
      if (result != null) {
        debugPrint("✅ Shop image uploaded: $result");
        return result;
      } else {
        debugPrint("❌ Shop upload failed");
        return null;
      }
    }
  } catch (e) {
    debugPrint("❌ Upload error: $e");
    return null;
  }
}
