import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/email_service.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    print('🔵 Kayıt işlemi başlatılıyor...');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validasyonu başarısız');
      return;
    }

    print('✅ Form validasyonu başarılı');
    print('📧 Email: ${_emailController.text.trim()}');

    setState(() {
      _isLoading = true;
    });

    try {
      print('📝 Firestore\'a kayıt yapılıyor...');
      // Register pending admin
      final token = await _firestoreService.registerPendingAdmin(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print('✅ Firestore kaydı başarılı, token: $token');

      // Create verification and reject links
      final verificationLink = EmailService.createVerificationLink(token);
      final rejectLink = EmailService.createRejectLink(token);
      print('🔗 Verification link oluşturuldu: $verificationLink');
      print('🔴 Reject link oluşturuldu: $rejectLink');

      // Send verification email
      print('📧 E-posta gönderiliyor...');
      await EmailService.sendVerificationEmail(
        toEmail: _emailController.text.trim(),
        verificationToken: token,
        verificationLink: verificationLink,
        rejectLink: rejectLink,
      );
      print('✅ E-posta gönderildi');

      if (!mounted) return;

      // Show success message with verification link
      print('✅ Kayıt işlemi tamamlandı, başarı dialogu gösteriliyor');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          title: const Text(
            'Kayıt Başarılı',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kayıt işleminiz tamamlandı. Onay isteği gönderildi. '
                  'Hesabınız onaylandıktan sonra giriş yapabileceksiniz.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Onay Linki (Email gelmediyse bu linki kullanın):',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1929),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: SelectableText(
                    verificationLink,
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Not: Email göndermek için Firebase Cloud Functions kurulumu gereklidir. '
                  'Detaylar için QUICK_EMAIL_SETUP.md dosyasına bakın.',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to login
              },
              child: const Text('Tamam', style: TextStyle(color: Color(0xFF2196F3))),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      print('❌ HATA: $e');
      print('📚 Stack trace: $stackTrace');
      if (!mounted) return;
      
      // Timeout hatası için özel dialog
      final errorMessage = e.toString();
      if (errorMessage.contains('zaman aşımı') || errorMessage.contains('timeout')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A2332),
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Firestore Bağlantı Hatası',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firestore Security Rules yazma izni vermiyor.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Çözüm:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StepWidget('1', 'Firebase Console\'a gidin: console.firebase.google.com'),
                  _StepWidget('2', 'Projenizi seçin: bmt-web-41790'),
                  _StepWidget('3', 'Firestore Database > Rules sekmesine gidin'),
                  _StepWidget('4', 'TÜM mevcut kuralları silin (Ctrl+A, Delete)'),
                  _StepWidget('5', 'Aşağıdaki kuralları yapıştırın:'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1929),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SelectableText(
                      'rules_version = \'2\';\n'
                      'service cloud.firestore {\n'
                      '  match /databases/{database}/documents {\n'
                      '    match /pending_admins/{document=**} {\n'
                      '      allow read, write: if true;\n'
                      '    }\n'
                      '    match /events/{document=**} {\n'
                      '      allow read, write: if true;\n'
                      '    }\n'
                      '    match /admins/{document=**} {\n'
                      '      allow read, write: if true;\n'
                      '    }\n'
                      '  }\n'
                      '}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StepWidget('6', 'Publish butonuna tıklayın (sağ üstte)'),
                  _StepWidget('7', '10-30 saniye bekleyin (rules yayınlanıyor)'),
                  _StepWidget('8', 'Uygulamayı yeniden başlatın (R tuşu)'),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  const Text(
                    '💡 Alternatif: Test Mode (Daha Kolay)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Firebase Console > Firestore Database > Overview\'da "Test mode" seçeneğini kullanabilirsiniz. Bu 30 gün boyunca herkesin yazmasına izin verir ve rules ayarlamaya gerek kalmaz.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam', style: TextStyle(color: Color(0xFF2196F3))),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('🔄 Loading durumu false olarak ayarlandı');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Kayıt',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin hesabı oluşturmak için kayıt olun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.email, color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF0A1929),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-posta adresi gerekli';
                      }
                      if (!value.contains('@')) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0A1929),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre gerekli';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Şifre Tekrar',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0A1929),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre tekrarı gerekli';
                      }
                      if (value != _passwordController.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        print('🔘 Kayıt Ol butonuna tıklandı');
                        _register();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Zaten hesabınız var mı? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/admin-login'),
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(color: Color(0xFF2196F3)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for step display
class _StepWidget extends StatelessWidget {
  final String number;
  final String text;

  const _StepWidget(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

