import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/firestore_provider.dart';
import '../providers/auth_provider.dart';
import 'dart:html' as html show window;

class AdminVerifyPage extends StatefulWidget {
  final String? token;

  const AdminVerifyPage({super.key, this.token});

  @override
  State<AdminVerifyPage> createState() => _AdminVerifyPageState();
}

class _AdminVerifyPageState extends State<AdminVerifyPage> {
  bool _isLoading = true;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Token'ı kontrol et ve debug log ekle
    print('🔍 AdminVerifyPage initState - Token: ${widget.token}');
    print('🔍 kIsWeb: $kIsWeb');
    
    if (kIsWeb) {
      // ignore: avoid_web_libraries_in_flutter
      final fullUrl = html.window.location.href;
      final hash = html.window.location.hash;
      final search = html.window.location.search ?? '';
      
      print('🔍 Full URL: $fullUrl');
      print('🔍 Hash: $hash');
      print('🔍 Search: $search');
      
      String? token = widget.token;
      
      // Token yoksa veya boşsa, URL'den parse et
      if (token == null || token.isEmpty) {
        // Yöntem 1: Hash'ten parse et (#/admin-verify?token=xxx)
        if (hash.isNotEmpty) {
          if (hash.contains('?')) {
            final hashParts = hash.split('?');
            if (hashParts.length > 1) {
              final queryString = hashParts[1];
              print('🔍 Query string from hash: $queryString');
              try {
                final queryUri = Uri.parse('?$queryString');
                token = queryUri.queryParameters['token'];
                print('🔍 Token from hash query: $token');
              } catch (e) {
                print('⚠️ Hash query parse hatası: $e');
              }
            }
          }
          
          // Alternatif: Hash içinde direkt token ara
          if (token == null || token.isEmpty) {
            final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
            if (tokenMatch != null && tokenMatch.group(1) != null) {
              token = Uri.decodeComponent(tokenMatch.group(1)!);
              print('🔍 Token from hash regex: $token');
            }
          }
        }
        
        // Yöntem 2: Search'ten parse et (?token=xxx)
        if ((token == null || token.isEmpty) && search.isNotEmpty) {
          try {
            final searchUri = Uri.parse(search);
            token = searchUri.queryParameters['token'];
            print('🔍 Token from search: $token');
          } catch (e) {
            print('⚠️ Search parse hatası: $e');
          }
        }
        
        // Yöntem 3: Full URL'den parse et
        if (token == null || token.isEmpty) {
          try {
            final fullUri = Uri.parse(fullUrl);
            token = fullUri.queryParameters['token'];
            print('🔍 Token from full URL: $token');
          } catch (e) {
            print('⚠️ Full URL parse hatası: $e');
          }
        }
      }
      
      if (token != null && token.isNotEmpty) {
        print('✅ Token bulundu: $token');
        _verifyToken(token);
      } else {
        print('❌ Token bulunamadı');
        // Biraz bekle ve tekrar kontrol et (hash routing için)
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            final hash = html.window.location.hash;
            print('🔍 Delayed check - Hash: $hash');
            
            if (hash.isNotEmpty && hash.contains('token=')) {
              final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
              if (tokenMatch != null && tokenMatch.group(1) != null) {
                final token = Uri.decodeComponent(tokenMatch.group(1)!);
                print('✅ Token bulundu (delayed): $token');
                _verifyToken(token);
                return;
              }
            }
            
            setState(() {
              _isLoading = false;
              _message = 'Geçersiz onay linki. Token bulunamadı.\n\n'
                  'Lütfen email\'deki linki tekrar kontrol edin veya linki tarayıcıya kopyalayıp yapıştırın.\n\n'
                  'URL: $fullUrl\n'
                  'Hash: $hash';
              _isSuccess = false;
            });
          }
        });
      }
    } else if (widget.token != null && widget.token!.isNotEmpty) {
      print('✅ Token widget\'tan alındı: ${widget.token}');
      _verifyToken(widget.token!);
    } else {
      print('❌ Token bulunamadı veya boş');
      setState(() {
        _isLoading = false;
        _message = 'Geçersiz onay linki. Token bulunamadı.\n\n'
            'Lütfen email\'deki linki tekrar kontrol edin.';
        _isSuccess = false;
      });
    }
  }

  Future<void> _verifyToken(String token) async {
    if (token.isEmpty) {
      print('❌ Token boş!');
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'Geçersiz onay linki. Token bulunamadı.';
      });
      return;
    }

    final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print('🔍 Token doğrulanıyor: $token');
      print('📝 Token uzunluğu: ${token.length}');
      
      // Verify admin
      print('📤 FirestoreProvider.verifyAdmin çağrılıyor...');
      final adminData = await firestoreProvider.verifyAdmin(token);
      print('✅ verifyAdmin yanıtı alındı: $adminData');
      
      final email = adminData['email']!;
      final password = adminData['password']!;
      
      print('✅ Admin doğrulandı: $email');
      print('🔑 Password uzunluğu: ${password.length}');

      // Firebase Auth kullanıcısını oluştur veya giriş yap
      try {
        // Önce giriş yapmayı dene
        print('🔐 Giriş yapılıyor...');
        await authProvider.signIn(email, password);
        print('✅ Giriş başarılı');
      } catch (e) {
        print('⚠️ Giriş hatası: $e');
        // Eğer kullanıcı yoksa, oluştur
        if (e.toString().contains('user-not-found') || 
            e.toString().contains('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı')) {
          print('👤 Kullanıcı oluşturuluyor...');
          await authProvider.createUserWithEmailAndPassword(email, password);
          print('✅ Kullanıcı oluşturuldu');
        } else {
          // Diğer hatalar için tekrar dene
          print('🔄 Tekrar giriş deneniyor...');
          await authProvider.signIn(email, password);
          print('✅ Giriş başarılı (ikinci deneme)');
        }
      }

      if (!mounted) return;

      print('✅ Onay işlemi tamamlandı');
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = 'Hesabınız başarıyla onaylandı!\n\nArtık giriş yapabilirsiniz.';
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
          errorMessage = 'Geçersiz veya kullanılmış onay linki.\n\nLütfen yeni bir kayıt yapın veya admin panelinden manuel onay isteyin.';
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
      backgroundColor: const Color(0xFF0A0E17),
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
                _isSuccess ? 'Hesap Onaylandı' : 'Onay Hatası',
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

