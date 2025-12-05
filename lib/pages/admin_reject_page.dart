import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AdminRejectPage extends StatefulWidget {
  final String? token;

  const AdminRejectPage({super.key, this.token});

  @override
  State<AdminRejectPage> createState() => _AdminRejectPageState();
}

class _AdminRejectPageState extends State<AdminRejectPage> {
  final _firestoreService = FirestoreService();
  bool _isLoading = true;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _rejectToken(widget.token!);
    } else {
      setState(() {
        _isLoading = false;
        _message = 'Geçersiz red linki.';
        _isSuccess = false;
      });
    }
  }

  Future<void> _rejectToken(String token) async {
    try {
      // Reject admin (delete from pending_admins)
      await _firestoreService.rejectAdmin(token);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = 'Kayıt talebi başarıyla reddedildi.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF44336)),
                )
              else
                Icon(
                  _isSuccess ? Icons.cancel : Icons.error,
                  size: 80,
                  color: _isSuccess ? Colors.orange : Colors.red,
                ),
              const SizedBox(height: 24),
              Text(
                _isSuccess ? 'Red İşlemi Tamamlandı' : 'Red Hatası',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_message != null)
                Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess ? Colors.white70 : Colors.red[300],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Ana Sayfaya Dön'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

