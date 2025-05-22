import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class ApiService {
  // Mock user database (stored locally for testing)
  static final Map<String, Map<String, String>> _mockUsers = {};

  Future<User> register(String name, String studentId, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUsers.containsKey(email)) {
      throw Exception('User with this email already exists');
    }

    _mockUsers[email] = {
      'name': name,
      'studentId': studentId,
      'email': email,
      'password': password,
    };

    return User(name: name, studentId: studentId, email: email, token: '');
  }

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!_mockUsers.containsKey(email)) {
      throw Exception('User not found');
    }
    if (_mockUsers[email]!['password'] != password) {
      throw Exception('Incorrect password');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('token', token);
    await prefs.setString('user_name', _mockUsers[email]!['name']!);

    return User(
      name: _mockUsers[email]!['name']!,
      studentId: _mockUsers[email]!['studentId']!,
      email: email,
      token: token,
    );
  }

  Future<ScanResponse> scanQrCode(String qrCode, String action) async {
    await Future.delayed(const Duration(seconds: 1));

    if (qrCode != 'campus-123') {
      throw Exception('Invalid QR code');
    }

    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();

    // Save last action
    await prefs.setString('last_action', action);
    await prefs.setString('last_timestamp', timestamp);

    // Update scan history
    List<String> history = prefs.getStringList('scan_history') ?? [];
    history.add('$action|$timestamp');
    await prefs.setStringList('scan_history', history);

    return ScanResponse(
      message: '$action recorded',
      timestamp: timestamp,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
    await prefs.remove('last_action');
    await prefs.remove('last_timestamp');
    await prefs.remove('scan_history');
  }
}

class ScanResponse {
  final String message;
  final String timestamp;

  ScanResponse({required this.message, required this.timestamp});
}
