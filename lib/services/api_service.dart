import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../screen/shared_prefs_helper.dart';

class ApiService {
  static const String _baseUrl = "http://192.168.35.243:3002/api";

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    SPrefs.getAccessToken().then((token) {
      if (token != null && token.isNotEmpty) {
        debugPrint(" LOADED TOKEN (auto): $token");
        setAccessToken(token);
      }
    });
  }


  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  String? _accessToken;

  String get baseHost {
    final uri = Uri.parse(_dio.options.baseUrl);
    return "${uri.scheme}://${uri.host}:${uri.port}";
  }

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
    required int userType,
    String? firstName,
    String? email,
  }) {
    return _dio.post('/auth/register', data: {
      'mobile_code': mobileCode,
      'mobile': mobile,
      'password': password,
      'role': userType,
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

  // ==============================
// GET USER PROFILE
// ==============================
  Future<Map<String, dynamic>> getUserProfile() async {
    final session = await SPrefs.readSession();
    final userId = session?['user_id'];

    final r = await _dio.get('/users/$userId');
    return r.data['status'] == true ? r.data['data'] : {};
  }

// ==============================
// UPDATE USER PROFILE
// ==============================
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    final session = await SPrefs.readSession();
    final userId = session?['user_id'];

    final r = await _dio.put('/users/$userId', data: data);
    return r.data['status'] == true;
  }


  // ---------------- DOCTOR PROFILE ----------------
  Future<Map<String, dynamic>> getDoctorProfile(int id) async {
    final res = await _dio.get("/doctors/$id");

    if (res.data["status"] == true && res.data["data"] != null) {
      return res.data["data"];  // only the data object
    }
    return {};
  }



  Future<Map<String, dynamic>> updateDoctorProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(
      '/admin/doctors/${data["doctor_id"]}',
      data: data,
    );
    return response.data;
  }


  // ---------------- SHOP PROFILE ----------------
  Future<Map<String, dynamic>> getShopProfile(int shopId) async {
    final response = await _dio.get('/shops/$shopId/profile');

    if (response.data["status"] == true && response.data["data"] != null) {
      return response.data["data"];
    }
    return {};
  }


  Future<Map<String, dynamic>> updateShopProfile(int shopId, Map<String, dynamic> data) async {
    final response = await _dio.put('/shops/$shopId', data: data);
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
  // ---------------- FEEDBACK ----------------
  Future<List<dynamic>> getDoctorFeedbacks(int doctorId) async {
    try {
      final response = await _dio.get('/doctors/$doctorId/feedback');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return (response.data['data'] as List);
      }
    } catch (e) {
      debugPrint("getDoctorFeedbacks error: $e");
    }
    return [];
  }

  Future<bool> addDoctorFeedback({
    required int doctorId,
    required int userId,
    required String message,
    required double rating,
  }) async {
    try {
      final res = await _dio.post(
        "/doctors/$doctorId/feedback",
        data: {
          "user_id": userId,
          "message": message,
          "rating": rating,
        },
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  // ---------------- APPOINTMENTS ----------------
  Future<bool> bookAppointment({
    required int doctorId,
    required int userId,
    required String date,
    required String reason,
    required String message,
  }) async {
    try {
      final dataBody = {
        'doctor_id': doctorId,
        'user_id': userId,
        'appointment_date': date,
        'reason': reason,
        'message': message,
      };

      print("📤 FLUTTER SENDING BODY: $dataBody");

      final res = await _dio.post(
        '/appointments/book',
        data: dataBody,
      );


      debugPrint(" APPOINTMENT RESPONSE: ${res.data}");
      return res.data['status'] == true;
    } catch (e) {
      debugPrint("Book Appointment Error: $e");
      return false;
    }
  }



  Future<List<dynamic>> getUserAppointments(int userId) async {
    try {
      final res = await _dio.get('/appointments/user/$userId');
      return res.data;
    } catch (e) {
      debugPrint("User appointment error: $e");
      return [];
    }
  }

  Future<List<dynamic>> getDoctorAppointments(int doctorId) async {
    try {
      final res = await _dio.get('/appointments/doctor/$doctorId');
      return res.data;
    } catch (e) {
      debugPrint("Doctor appointment error: $e");
      return [];
    }
  }

  Future<bool> updateAppointmentStatus({
    required int appointmentId,
    required String status, // 'approved' or 'cancelled'
  }) async {
    try {
      final res = await _dio.put(
        '/appointments/$appointmentId/status',
        data: {'status': status},
      );

      return res.data['success'] == true;
    } catch (e) {
      debugPrint("Status update error: $e");
      return false;
    }
  }





  Future<Map<String, dynamic>?> getMyShop() async {
    final session = await SPrefs.readSession();
    final shopId = session?['user_id'];

    final r = await _dio.get('/shops/$shopId');

    if (r.data['status'] == true) return r.data['data'];
    return null;
  }

  Future<Map<String, dynamic>> updateShop(int shopId, Map<String, dynamic> body) async {
    // backend uses POST /shops/update
    final r = await _dio.post('/shops/update', data: body);
    return r.data;
  }


// ---------------------------------------------------
  Future<List<dynamic>> getMedicalShopsByDivision(String divisionId) async {
    try {
      final response = await _dio.get(
        '/shops/by_division',
        queryParameters: {"division_id": divisionId},
      );

      if (response.data['status'] == true &&
          response.data['data'] is List) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint("ERROR getMedicalShopsByDivision: $e");
    }

    return [];
  }

// ---------------------------------------------------
// UPLOAD SHOP IMAGE
// ---------------------------------------------------
  Future<Map<String, dynamic>> uploadShopImage(int shopId, String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });

    final r = await _dio.post('/shops/$shopId/upload', data: formData);
    return r.data;
  }


// ---------------------------------------------------
// SHOP FEEDBACK
// ---------------------------------------------------
  Future<List<dynamic>> getShopFeedbacks(int shopId) async {
    final r = await _dio.get('/shops/$shopId/feedback');
    return r.data['status'] == true ? (r.data['data'] ?? []) : [];
  }

  Future<bool> addShopFeedback({
    required int shopId,
    required int userId,
    required String message,
    required double rating,
  }) async {
    try {
      final res = await _dio.post(
        "/shops/$shopId/feedback",
        data: {
          "user_id": userId,
          "message": message,
          "rating": rating,
        },
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendMessage(Map<String, dynamic> data) async {
    final response = await _dio.post("/chat/send", data: data);
    return response.data["status"] == 1;
  }

  Future<List<dynamic>> loadMessages(int userId, int otherId) async {
    final res = await _dio.post("/chat/load_messages", data: {
      "user_id": userId,
      "other_id": otherId,
    });

    if (res.data != null && res.data["status"] == 1) {
      return res.data["data"];
    }

    return [];
  }





  Future<List<dynamic>> loadChatList(int userId) async {
    final r = await _dio.get("/chat/user_list/$userId");
    return r.data["data"];
  }
// =============================
// GET RECENT CHATS FOR USER
// =============================
  Future<List<dynamic>> getRecentChats(int userId) async {
    try {
      final r = await _dio.get("/recent_chats/$userId");

      if (r.data["status"] == true || r.data["status"] == 1) {
        return r.data["data"] ?? [];
      }
      return [];
    } catch (e) {
      print("Error getRecentChats: $e");
      return [];
    }
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
