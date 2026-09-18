import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseBootstrap {
  static bool get isConfigured => SupabaseConfig.isConfigured;

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
  }

  static SupabaseClient? get client => isConfigured ? Supabase.instance.client : null;
}
