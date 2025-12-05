import '../secrets.dart';
import 'package:cloud_functions/cloud_functions.dart';

class EmailService {
  // Email gönderme fonksiyonu
  // Firebase Cloud Functions kullanarak email gönderir
  
  static Future<void> sendVerificationEmail({
    required String toEmail, // Kullanıcının email'i (bilgi amaçlı)
    required String verificationToken,
    required String verificationLink,
    required String rejectLink,
  }) async {
    // Onay maili secrets.dart'taki verificationEmailTo adresine gönderilecek
    final verificationEmailAddress = Secrets.verificationEmailTo;
    
    try {
      // Firebase Cloud Functions'ı çağır
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('sendVerificationEmail');
      
      print('📧 Email gönderiliyor: $verificationEmailAddress');
      print('👤 Kullanıcı email: $toEmail');
      print('🔗 Onay linki: $verificationLink');
      print('🔴 Red linki: $rejectLink');
      
      await callable.call({
        'to': verificationEmailAddress, // Onay maili bu adrese gidecek
        'userEmail': toEmail, // Kullanıcının email'i (email içeriğinde gösterilecek)
        'subject': 'BMT Web Sitesi Onay Maili',
        'token': verificationToken,
        'link': verificationLink,
        'rejectLink': rejectLink,
      });
      
      print('✅ Email başarıyla gönderildi');
    } catch (e) {
      print('❌ Email gönderme hatası: $e');
      // Hata olsa bile devam et (kullanıcıya link gösterilecek)
      // Production'da bu hatayı throw edebilirsiniz:
      // throw 'Email gönderilirken hata oluştu: $e';
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

  // Reject link oluştur
  static String createRejectLink(String token) {
    return 'https://${Secrets.firebaseAuthDomain}/#/admin-reject?token=$token';
  }
}

