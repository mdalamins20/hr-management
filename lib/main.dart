import 'package:flutter/material.dart';
import 'data/app_state.dart';
import 'data/binary_store.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the binary local storage. If storage is unavailable (tests,
  // unsupported environment) the app simply starts fresh in memory.
  try {
    await LocalStore.init();
    AppState.persistenceEnabled = true;
    final saved = LocalStore.load();
    if (saved != null) {
      appState = AppState.fromMap(saved);
    }
  } catch (_) {
    AppState.persistenceEnabled = false;
  }
  runApp(const HrApp());
}

class HrApp extends StatelessWidget {
  const HrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
