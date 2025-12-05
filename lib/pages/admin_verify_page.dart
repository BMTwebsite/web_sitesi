import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminVerifyPage extends StatefulWidget {
  final String? token;

  const AdminVerifyPage({super.key, this.token});

  @override
  State<AdminVerifyPage> createState() => _AdminVerifyPageState();
}

class _AdminVerifyPageState extends State<AdminVerifyPage> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  bool _isLoading = true;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _verifyToken(widget.token!);
    } else {
      setState(() {
        _isLoading = false;
        _message = 'Geçersiz onay linki.';
        _isSuccess = false;
      });
    }
  }

  Future<void> _verifyToken(String token) async {
    try {
      // Verify admin
      final adminData = await _firestoreService.verifyAdmin(token);
      final email = adminData['email']!;
      final password = adminData['password']!;

      // Create Firebase Auth user
      try {
        await _authService.signInWithEmailAndPassword(email, password);
      } catch (e) {
        // If user doesn't exist, create it
        if (e.toString().contains('user-not-found')) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = 'Hesabınız başarıyla onaylandı! Giriş yapabilirsiniz.';
      });

      // Navigate to login after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin-login');
        }
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                )
              else
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
              const SizedBox(height: 24),
              Text(
                _isSuccess ? 'Onay Başarılı!' : 'Onay Hatası',
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
              if (!_isLoading && !_isSuccess)
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/admin-login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Giriş Sayfasına Dön'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

