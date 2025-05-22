import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String lastStatus = "No Activity";
  String lastTime = "N/A";

  @override
  void initState() {
    super.initState();
    _loadLastActivity();
  }

  Future<void> _loadLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAction = prefs.getString('last_action');
    final lastTimestamp = prefs.getString('last_timestamp');
    setState(() {
      if (lastAction != null) {
        lastStatus = lastAction == 'entry' ? 'Clocked In' : 'Clocked Out';
      }
      if (lastTimestamp != null) {
        lastTime = _formatDateTime(DateTime.parse(lastTimestamp));
      }
    });
  }

  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _updateActivity(String action, String timestamp) {
    setState(() {
      lastStatus = action == 'entry' ? 'Clocked In' : 'Clocked Out';
      lastTime = _formatDateTime(DateTime.parse(timestamp));
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String userName = authProvider.user?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.deepPurple.shade50,
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            final result = await Navigator.pushNamed(context, '/scanner');
            if (result != null && result is Map<String, String>) {
              _updateActivity(result['action']!, result['timestamp']!);
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
        ],
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back!',
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(userName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.door_front_door,
                      color: Colors.deepPurple, size: 28),
                ),
                title: Text('Last Activity',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(lastStatus,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(lastTime, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text('Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
