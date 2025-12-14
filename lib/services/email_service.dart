import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import '../secrets.dart';

class EmailService {
  // Email gönderme fonksiyonu
  // Firebase Cloud Functions kullanarak email gönderir
  
  static Future<void> sendVerificationEmail({
    required String toEmail, // Kullanıcının email'i (bilgi amaçlı)
    required String verificationToken,
    required String verificationLink,
  }) async {
    // Onay maili secrets.dart'taki verificationEmailTo adresine gönderilecek
    final verificationEmailAddress = Secrets.verificationEmailTo;
    
    try {
      print('📧 E-posta gönderiliyor...');
      print('📬 Alıcı: $verificationEmailAddress');
      print('👤 Kullanıcı: $toEmail');
      print('🔗 Onay linki: $verificationLink');
      
      // Firebase Cloud Functions'ı çağır
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable(
        'sendVerificationEmail',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30), // 30 saniye timeout
        ),
      );
      
      final result = await callable.call({
        'to': verificationEmailAddress, // Onay maili bu adrese gidecek
        'userEmail': toEmail, // Kullanıcının email'i (email içeriğinde gösterilecek)
        'subject': 'BMT Web Sitesi Onay Maili',
        'token': verificationToken,
        'link': verificationLink,
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'E-posta gönderme işlemi zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.';
        },
      );
      
      print('✅ E-posta gönderme sonucu: ${result.data}');
      
      if (result.data['success'] != true) {
        throw 'E-posta gönderilemedi. Lütfen daha sonra tekrar deneyin.';
      }
    } catch (e) {
      print('❌ E-posta gönderme hatası: $e');
      // Hata mesajını kullanıcıya göster
      throw 'E-posta gönderilirken hata oluştu: ${e.toString()}';
    }
  }

  // Verification link oluştur
  static String createVerificationLink(String token) {
    // Web uygulamanızın URL'ini buraya ekleyin
    // Production için: https://your-domain.com/#/admin-verify?token=$token
    // Development için: http://localhost:5000/#/admin-verify?token=$token
    // Flutter web hash routing kullanıyor, bu yüzden # kullanıyoruz
    return 'https://${Secrets.firebaseAuthDomain}/#/admin-verify?token=$token';
  }
}

