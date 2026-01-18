import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'login_screen.dart';
import '../main_screen.dart'; // We will create this

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Artificial delay for branding
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();

    if (!mounted) return;

    if (userProvider.isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lumo',
                style: TextStyle(
                  fontFamily: 'Outfit', // Or specific script if available
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
