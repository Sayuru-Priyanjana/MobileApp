import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final error = await userProvider.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _imageFile,
      _bioController.text.trim(),
    );

    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Text(
                'Lumo',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Sign up to see photos and videos\nfrom your friends.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  backgroundColor:
                      Theme.of(context).cardTheme.color == Colors.black
                          ? Colors.grey[900]
                          : Colors.grey[200],
                  child:
                      _imageFile == null
                          ? Icon(
                            Icons.add_a_photo_outlined,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 8),
              if (_imageFile == null)
                const Text(
                  "Add Profile Photo",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

              const SizedBox(height: 32),

              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Username',
                prefixIcon: null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Email',
                prefixIcon: null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Password',
                isPassword: true,
                prefixIcon: null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Bio',
                maxLines: 2,
                prefixIcon: null,
              ),

              const SizedBox(height: 32),
              Consumer<UserProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: provider.isLoading ? null : _register,
                      text: 'Sign Up',
                      isLoading: provider.isLoading,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
