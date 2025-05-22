import 'package:flutter/material.dart';
import 'package:scan/scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = false;
  ScanController controller = ScanController();

  Future<void> _scanQRCode() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      String? qrCode = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SizedBox(
              height: 400,
              child: Stack(
                children: [
                  ScanView(
                    controller: controller,
                    scanAreaScale: 0.7,
                    scanLineColor: Colors.deepPurple,
                    onCapture: (data) {
                      Navigator.pop(context, data);
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (qrCode == null) {
        setState(() {
          _isScanning = false;
        });
        return;
      }

      if (qrCode != 'campus-123') {
        throw Exception('Invalid QR code');
      }

      final action = await _showEntryExitDialog();
      if (action == null) {
        setState(() {
          _isScanning = false;
        });
        return;
      }

      final scanResponse = await ApiService().scanQrCode(qrCode, action);

      final prefs = await SharedPreferences.getInstance();
      final timestamp = scanResponse.timestamp;

      await prefs.setString('last_action', action);
      await prefs.setString('last_timestamp', timestamp);

      final existingHistory = prefs.getStringList('scan_history') ?? [];
      existingHistory.add('$action|$timestamp');
      await prefs.setStringList('scan_history', existingHistory);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${scanResponse.message} at ${DateTime.parse(timestamp).toLocal()}'),
        ),
      );

      // Return result to HomeScreen to update immediately
      Navigator.pop(context, {'action': action, 'timestamp': timestamp});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<String?> _showEntryExitDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark Attendance'),
          content: const Text('Please select whether this is an entry or exit.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'entry'),
              child: const Text('Mark as Entry'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'exit'),
              child: const Text('Mark as Exit'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Scan Campus QR Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Expanded(
              flex: 4,
              child: Center(
                child: ElevatedButton(
                  onPressed: _isScanning ? null : _scanQRCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isScanning ? 'Scanning...' : 'Start Scan',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildInfoCard(
              icon: Icons.qr_code_scanner,
              title: 'Ready to Scan',
              description:
                  'Tap the button to start scanning the official campus attendance QR code to mark your entry or exit.',
              iconColor: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            buildInfoCard(
              icon: Icons.info_outline,
              title: 'Tips for Scanning',
              description:
                  'Ensure good lighting, hold steady, and clean your camera lens for best results.',
              iconColor: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
