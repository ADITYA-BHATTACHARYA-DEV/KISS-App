import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vermeni/screens/home_screen.dart';
import 'package:vermeni/screens/settings_page.dart';
import 'package:vermeni/services/theme_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gemini Voice Assistant',
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4B0082),
              brightness: Brightness.light,
              primary: const Color(0xFF4B0082),
              secondary: Colors.blueAccent,
              background: Colors.white,
              surface: const Color(0xFFEDE7F6),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Colors.black87,
              onSurface: Colors.black87,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme(
              brightness: Brightness.dark,
              primary: const Color(0xFF4B0082),
              onPrimary: Colors.white,
              secondary: Colors.blueAccent,
              onSecondary: Colors.white,
              background: Colors.black,
              onBackground: Colors.white,
              surface: const Color(0xFF121212),
              onSurface: Colors.white,
              error: Colors.redAccent,
              onError: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF4B0082),
              foregroundColor: Colors.white,
            ),
            useMaterial3: true,
          ),
          themeMode: themeService.themeMode,
          home: const HomeScreen(),
          routes: {
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
