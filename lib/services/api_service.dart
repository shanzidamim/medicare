import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ApiService {
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: "http://192.168.225.243:3002/api",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  String? _accessToken;

  void setAccessToken(String? t) {
    _accessToken = t;
    _dio.interceptors.clear();
    if (t != null && t.isNotEmpty) {
      _dio.interceptors.add(
        InterceptorsWrapper(onRequest: (options, handler) {
          options.headers['access_token'] = t;
          return handler.next(options);
        }),
      );
    }
  }

  // ---------------- AUTH ----------------
  Future<Response> register({
    required String mobileCode,
    required String mobile,
    required String password,
    required int userType, // 1=user, 2=doctor, 3=medical shop
    String? firstName,
    String? email,
  }) {
    return _dio.post('/auth/register', data: {
      'mobile_code': mobileCode,
      'mobile': mobile,
      'password': password,
      'role': userType, // ✅ changed from user_type → role
      if (firstName != null) 'first_name': firstName,
      if (email != null) 'email': email,
    });
  }

  Future<Response> login({
    required String mobileCode,
    required String mobile,
    required String password,
  }) {
    return _dio.post('/auth/login', data: {
      'mobile_code': mobileCode,
      'mobile': mobile,
      'password': password,
    });
  }


  // ---------------- DOCTOR PROFILE ----------------
  Future<Map<String, dynamic>> getDoctorProfile(int doctorId) async {
    final response = await _dio.get('/doctor/$doctorId');
    return response.data;
  }

  Future<Map<String, dynamic>> updateDoctorProfile(Map<String, dynamic> data) async {
    final response = await _dio.post('/doctor/update', data: data);
    return response.data;
  }

  // ---------------- SHOP PROFILE ----------------
  Future<Map<String, dynamic>> getShopProfile(int shopId) async {
    final response = await _dio.get('/shop/$shopId');
    return response.data;
  }

  Future<Map<String, dynamic>> updateShopProfile(Map<String, dynamic> data) async {
    final response = await _dio.post('/shop/update', data: data);
    return response.data;
  }

  // ---------------- DIVISIONS ----------------
  Future<List<dynamic>> getDivisions() async {
    try {
      final r = await _dio.get('/divisions');
      return r.data['status'] == true ? (r.data['data'] as List) : [];
    } catch (_) {
      return [];
    }
  }

  // ---------------- CATEGORIES ----------------
  Future<List<dynamic>> getCategories() async {
    try {
      final r = await _dio.get('/categories');
      return r.data['status'] == true ? (r.data['data'] as List) : [];
    } catch (_) {
      return [];
    }
  }

  // ---------------- DOCTORS ----------------
  Future<List<dynamic>> getDoctorsByDivision(int divisionId) async {
    try {
      final r = await _dio.get('/doctors/division/$divisionId');
      return r.data['status'] == true ? (r.data['data'] as List) : [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getDoctorsByDivisionAndCategory(
      int divisionId, int categoryId) async {
    try {
      final r = await _dio.get('/doctors/filter', queryParameters: {
        'division_id': divisionId,
        'category_id': categoryId,
      });
      return r.data['status'] == true ? (r.data['data'] as List) : [];
    } catch (_) {
      return [];
    }
  }

  // ---------------- FEEDBACK ----------------
  Future<List<dynamic>> getDoctorFeedbacks(int doctorId) async {
    final r = await _dio.get('/doctors/$doctorId/feedback');
    return r.data['status'] == true ? (r.data['data'] as List) : [];
  }

  Future<bool> addDoctorFeedback({
    required int doctorId,
    required int userId,
    required String message,
  }) async {
    final r = await _dio.post('/doctors/$doctorId/feedback', data: {
      'user_id': userId,
      'message': message,
    });
    return r.data['status'] == true;
  }

  // ---------------- CHAT ----------------
  Future<List<dynamic>> getChat({
    required int doctorId,
    required int userId,
  }) async {
    final r = await _dio.get('/chat/$doctorId/$userId');
    return r.data['status'] == true ? (r.data['data'] as List) : [];
  }

  Future<bool> sendChat({
    required int doctorId,
    required int userId,
    required String sender,
    required String message,
  }) async {
    final r = await _dio.post('/chat/send', data: {
      'doctor_id': doctorId,
      'user_id': userId,
      'sender': sender,
      'message': message,
    });
    return r.data['status'] == true;
  }

  // ---------------- APPOINTMENTS ----------------
  Future<bool> bookAppointment({
    required int doctorId,
    required int userId,
    required String date,
    required String reason,
    required String message,
  }) async {
    final r = await _dio.post('/appointments', data: {
      'doctor_id': doctorId,
      'user_id': userId,
      'date': date,
      'reason': reason,
      'message': message,
    });
    return r.data['status'] == true;
  }

  // ---------------- SHOPS ----------------
  Future<Map<String, dynamic>?> getMyShop() async {
    final r = await _dio.get('/shops/me');
    if (r.data['status'] == true) return r.data['data'] as Map<String, dynamic>?;
    return null;
  }

  Future<bool> createShop(Map<String, dynamic> body) async {
    final r = await _dio.post('/shops/create', data: body);
    return r.data['status'] == true;
  }

  Future<bool> updateShop(int shopId, Map<String, dynamic> body) async {
    final r = await _dio.put('/shops/$shopId', data: body);
    return r.data['status'] == true;
  }

  Future<List<dynamic>> getMedicalShopsByDivision(String divisionName) async {
    try {
      final response = await _dio.get('/shops/by_division', queryParameters: {
        'division': divisionName,
      });
      if (response.data['status'] == true) {
        return response.data['data'] as List;
      }
    } catch (e) {
      debugPrint("getMedicalShopsByDivision error: $e");
    }
    return [];
  }


  Future<String?> uploadShopImage(int shopId, String filePath) async {
    final fd = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post('/shops/$shopId/upload', data: fd);
    if (r.data['status'] == true) return r.data['image_url'] as String?;
    return null;
  }
  // 🔹 Get shop feedbacks
  Future<List<dynamic>> getShopFeedbacks(int shopId) async {
    final r = await _dio.get('/shops/$shopId/feedback');
    return r.data['status'] == true ? (r.data['data'] as List) : [];
  }

// 🔹 Add shop feedback
  Future<bool> addShopFeedback({
    required int shopId,
    required int userId,
    required String message,
  }) async {
    final r = await _dio.post('/shops/$shopId/feedback', data: {
      'user_id': userId,
      'message': message,
    });
    return r.data['status'] == true;
  }



  // ---------------- DOCTOR IMAGE UPLOAD ----------------
  Future<Map<String, dynamic>> uploadDoctorImage(int doctorId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post('/doctors/$doctorId/upload', data: formData);

      if (response.data['status'] == true) {
        return {
          'status': true,
          'image_url': response.data['image_url'],
          'message': 'Doctor image uploaded successfully',
        };
      } else {
        return {
          'status': false,
          'message': response.data['message'] ?? 'Failed to upload doctor image',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }
}
