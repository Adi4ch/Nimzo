import 'package:flutter/material.dart';

import 'app.dart';
import 'config/supabase_bootstrap.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await SupabaseBootstrap.initialize();
	runApp(const NimzoApp());
}
