import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_profile.dart';

class AuthService {
  // Get current user ID from stored token (simplification: we'll use SharedPreferences to store the ID too)
  Future<int?> get currentUserId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('auth_user_id');
  }

  // Sign in with register number (for students) or email (for admins)
  Future<Map<String, dynamic>> signIn(String identifier, String password, {bool isAdmin = false}) async {
    try {
      final url = isAdmin 
          ? Uri.parse('${ApiConfig.baseUrl}/auth/admin/login')
          : Uri.parse('${ApiConfig.baseUrl}/auth/student/login');
      
      final body = isAdmin 
          ? {'email': identifier, 'password': password}
          : {'reg_no': identifier, 'password': password};

      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(null),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final profile = UserProfile.fromJson(data['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setInt('auth_user_id', profile.id);
        
        return {
          'success': true,
          'user': profile,
          'role': profile.role,
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Sign up new user
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    String? regNo,
    int? departmentId,
    int? year,
    String? phone,
    bool isAdmin = false,
  }) async {
    try {
      final url = isAdmin 
          ? Uri.parse('${ApiConfig.baseUrl}/auth/admin/register')
          : Uri.parse('${ApiConfig.baseUrl}/auth/student/register');
      
      final body = isAdmin 
          ? {
              'name': name,
              'email': email,
              'password': password,
              'role': 'Admin',
            }
          : {
              'reg_no': regNo,
              'name': name,
              'email': email,
              'phone': phone,
              'department_id': departmentId,
              'year': year,
              'password': password,
            };

      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(null),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Account created successfully',
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Sign up failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Sign out
  Future<void> signOut() async {
    await ApiConfig.removeToken();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await ApiConfig.getToken();
    return token != null;
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(int userId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/students/profile/$userId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile(int userId, Map<String, dynamic> updates) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/students/profile/$userId'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(updates),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
