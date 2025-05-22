import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        nameController.text,
        idController.text,
        emailController.text,
        passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful! Please log in.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Center(
                child: Text(
                  'Student Registration',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Enter your details below to register for the Campus Attendance Tracker.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 32),
              CustomTextField(
                controller: nameController,
                labelText: 'Name',
                hintText: 'Your Full Name',
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: idController,
                labelText: 'Student ID',
                hintText: 'Your Student ID (e.g., 123456)',
                helperText:
                    'Enter the official student ID provided by the university.',
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                labelText: 'Email',
                hintText: 'university.email@campus.edu',
                helperText: 'Use your official university email address.',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Choose a strong password',
                helperText:
                    'Minimum 8 characters, including uppercase, lowercase,\nnumbers, and symbols.',
                obscureText: true,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        child: Text('Register'),
                      ),
              ),
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.grey[700]),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}