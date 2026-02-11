import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {'success': false, 'message': 'Login failed'};
      }

      // Fetch user profile to get role
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      final profile = UserProfile.fromJson(profileData);

      return {
        'success': true,
        'user': response.user,
        'profile': profile,
        'role': profile.role,
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Sign up new user (admin only)
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? registerNumber,
    String? department,
    int? year,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {'success': false, 'message': 'Sign up failed'};
      }

      // Create or update profile (upsert based on email)
      await _supabase.from('profiles').upsert({
        'id': response.user!.id, // Ensure the profile now uses the real Auth ID
        'name': name,
        'email': email,
        'register_number': registerNumber,
        'department': department,
        'year': year,
        'role': role,
      }, onConflict: 'email');

      return {
        'success': true,
        'user': response.user,
        'message': 'Account created successfully',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
