import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://eqrxzrfpjzqqlbvgwesx.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_S6jTJXJXcDPOJ9O_uQGNaA_ile8fusa';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
