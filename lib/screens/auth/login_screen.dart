import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final error = await userProvider.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(child: Container(), flex: 1), // Top Spacer

            Text(
              'Lumo',
              style: TextStyle(
                fontFamily: 'Outfit', // Or 'Billabong' if available?
                fontSize: 50,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color:
                    Theme.of(context).cardColor == Colors.black
                        ? Colors.white
                        : Colors.black,
              ),
            ),
            const SizedBox(height: 48),

            // Inputs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Phone number, username, or email',
                    prefixIcon: null, // Insta fields are simple
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Password',
                    isPassword: true,
                    prefixIcon: null,
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: provider.isLoading ? null : _login,
                          text: 'Log In',
                          isLoading: provider.isLoading,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Flexible(child: Container(), flex: 2), // Bottom Spacer
            // Bottom Sign Up
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      ' Sign up.',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
