import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/feed_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'firebase_options.dart'; // Will error if not present, but user must configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Attempt to use generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase Init Error (Using Default/Manual?): $e");
    try {
      // Fallback for web or if options missing but config in place?
      // Or just try default init if CLI failed
      await Firebase.initializeApp();
    } catch (e2) {
      print("Failed to initialize Firebase: $e2");
    }
  }

  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: MaterialApp(
        title: 'Lumo — Your World, Illuminated',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
