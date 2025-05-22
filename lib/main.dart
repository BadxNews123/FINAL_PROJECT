import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(StudentEntryExitApp());
}

class StudentEntryExitApp extends StatelessWidget {
  const StudentEntryExitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..initialize(),
      child: MaterialApp(
        title: 'Student Entry Exit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/scanner': (context) => QRScannerScreen(),
        },
      ),
    );
  }
}