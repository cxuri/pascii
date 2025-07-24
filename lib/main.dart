import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pascii/pages/home_page.dart';
import 'package:pascii/pages/new_pass.dart';
import 'package:pascii/pages/settings.dart';
import 'package:pascii/pages/operations.dart';
import 'package:pascii/pages/theme_select.dart';
import 'package:pascii/apptheme.dart';
import 'package:pascii/services/biometrics.dart';
import 'package:pascii/pages/note_view.dart';
import 'package:pascii/services/local_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  try {
    // Initialize LocalStorageService first
    await LocalStorage().init();

    // Then perform biometric authentication
    bool isAuthenticated = await authenticateUser();

    if (!isAuthenticated) {
      exit(0); // Close the app if authentication fails
    }

    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Initialization failed: $e');
    exit(1);
  }
}

Future<bool> authenticateUser() async {
  final Biometrics _biometrics = Biometrics();
  bool isBiometricAvailable = await _biometrics.canAuthenticate();
  if (isBiometricAvailable) {
    return await _biometrics.authenticate();
  }
  return false;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Moved from initState to didChangeDependencies
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/home',
          routes: {
            '/settings': (context) => const SettingsPage(),
            '/operations': (context) => const Operations(),
            '/new_password': (context) => const NewPass(),
            '/home': (context) => const HomePage(),
            '/new_note': (context) => const NoteViewPage(),
            '/theme': (context) => const ThemeSelectionPage(),
          },
          theme: themeNotifier.currentTheme.themeData,
          builder: (context, child) {
            return AnimatedTheme(
              data: themeNotifier.currentTheme.themeData,
              duration: const Duration(milliseconds: 300),
              child: child!,
            );
          },
        );
      },
    );
  }
}
