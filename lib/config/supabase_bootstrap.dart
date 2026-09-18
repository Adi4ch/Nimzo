import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseBootstrap {
  static bool _initialized = false;

  static bool get isConfigured => SupabaseConfig.isConfigured && _initialized;

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  static SupabaseClient? get client => isConfigured ? Supabase.instance.client : null;
}
