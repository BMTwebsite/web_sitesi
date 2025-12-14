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
    // Token'ı kontrol et ve debug log ekle
    print('🔍 AdminVerifyPage initState - Token: ${widget.token}');
    if (widget.token != null && widget.token!.isNotEmpty) {
      _verifyToken(widget.token!);
    } else {
      print('❌ Token bulunamadı veya boş');
      setState(() {
        _isLoading = false;
        _message = 'Geçersiz onay linki. Token bulunamadı.';
        _isSuccess = false;
      });
    }
  }

  Future<void> _verifyToken(String token) async {
    try {
      print('🔍 Token doğrulanıyor: $token');
      
      // Verify admin
      final adminData = await _firestoreService.verifyAdmin(token);
      final email = adminData['email']!;
      final password = adminData['password']!;
      
      print('✅ Admin doğrulandı: $email');

      // Firebase Auth kullanıcısını oluştur veya giriş yap
      try {
        // Önce giriş yapmayı dene
        print('🔐 Giriş yapılıyor...');
        await _authService.signInWithEmailAndPassword(email, password);
        print('✅ Giriş başarılı');
      } catch (e) {
        print('⚠️ Giriş hatası: $e');
        // Eğer kullanıcı yoksa, oluştur
        if (e.toString().contains('user-not-found') || 
            e.toString().contains('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı')) {
          print('👤 Kullanıcı oluşturuluyor...');
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ Kullanıcı oluşturuldu');
        } else {
          // Diğer hatalar için tekrar dene
          print('🔄 Tekrar giriş deneniyor...');
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ Giriş başarılı (ikinci deneme)');
        }
      }

      if (!mounted) return;

      print('✅ Onay işlemi tamamlandı');
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = 'Onay Verildi!\n\nHesabınız başarıyla onaylandı ve giriş yaptınız.';
      });

      // Admin paneline yönlendir (3 saniye sonra)
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          print('🔄 Admin paneline yönlendiriliyor...');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin-panel',
            (route) => false, // Tüm önceki route'ları temizle
          );
        }
      });
    } catch (e, stackTrace) {
      print('❌ Onay hatası: $e');
      print('📚 Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        // Daha anlaşılır hata mesajı
        String errorMessage = 'Onay işlemi başarısız oldu.';
        if (e.toString().contains('Geçersiz') || e.toString().contains('geçersiz')) {
          errorMessage = 'Geçersiz veya kullanılmış onay linki.';
        } else if (e.toString().contains('timeout') || e.toString().contains('zaman aşımı')) {
          errorMessage = 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
        } else {
          errorMessage = 'Hata: ${e.toString()}';
        }
        _message = errorMessage;
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
                _isSuccess ? 'Onay Verildi!' : 'Onay Hatası',
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
              if (!_isLoading && _isSuccess)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/admin-panel',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Admin Paneline Git'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

