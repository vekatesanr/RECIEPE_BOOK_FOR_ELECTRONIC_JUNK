import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/dismantle_screen.dart';
import 'screens/developer_screen.dart';
import 'screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  try {
    // Android automatically loads settings from the google-services.json file you placed!
    await Firebase.initializeApp(); 
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const EJunkApp());
}

class EJunkApp extends StatelessWidget {
  const EJunkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electronic Junk Recipe Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0f172a),
        primaryColor: const Color(0xFF10b981),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10b981),
          secondary: Color(0xFF34d399),
          surface: Color(0xFF1e293b),
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        cardColor: const Color(0xFF1e293b),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1e293b),
          foregroundColor: Color(0xFF10b981),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF10b981),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10b981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1e293b),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF10b981), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF94a3b8)),
          hintStyle: const TextStyle(color: Color(0xFF64748b)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF10b981),
          foregroundColor: Colors.white,
        ),
        dividerColor: const Color(0xFF334155),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFe2e8f0),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: Color(0xFFcbd5e1), fontSize: 15),
          bodyMedium: TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/analysis': (context) => const AnalysisScreen(),
        '/dismantle': (context) => const DismantleScreen(),
        '/developer': (context) => const DeveloperScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
