import '../secrets.dart';

class EmailService {
  // Bu servis Firebase Cloud Functions veya başka bir email servisi ile entegre edilebilir
  // Şimdilik basit bir HTTP endpoint kullanıyoruz
  
  // Email gönderme fonksiyonu
  // Not: Bu fonksiyon bir backend servisi gerektirir
  // Firebase Cloud Functions kullanarak email gönderebilirsiniz
  
  static Future<void> sendVerificationEmail({
    required String toEmail, // Kullanıcının email'i (bilgi amaçlı)
    required String verificationToken,
    required String verificationLink,
  }) async {
    // Onay maili secrets.dart'taki verificationEmailTo adresine gönderilecek
    final verificationEmailAddress = Secrets.verificationEmailTo;
    
    // Firebase Cloud Functions endpoint'i
    // Not: Firebase Cloud Functions'ı deploy ettikten sonra bu URL'yi güncelleyin
    // Örnek: https://us-central1-bmt-web-41790.cloudfunctions.net/sendVerificationEmail
    // final url = 'https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/sendVerificationEmail';
    
    try {
      // Firebase Cloud Functions'ı çağır
      // Not: Bu kısım için firebase_functions paketi gerekebilir
      // Alternatif olarak HTTP callable function kullanabilirsiniz
      
      // Şimdilik sadece log yazdırıyoruz
      // Gerçek uygulamada Firebase Cloud Functions'ı deploy edip burayı aktifleştirin
      print('📧 Verification email would be sent to: $verificationEmailAddress');
      print('👤 User email: $toEmail');
      print('🔗 Verification link: $verificationLink');
      print('⚠️  Note: Email göndermek için Firebase Cloud Functions deploy edilmelidir.');
      print('📝 See functions/index.js for Cloud Functions code.');
      
      // TODO: Firebase Cloud Functions deploy edildikten sonra bu kodu aktifleştirin
      // final functions = FirebaseFunctions.instance;
      // final callable = functions.httpsCallable('sendVerificationEmail');
      // await callable.call({
      //   'to': verificationEmailAddress, // Onay maili bu adrese gidecek
      //   'userEmail': toEmail, // Kullanıcının email'i (email içeriğinde gösterilecek)
      //   'subject': 'BMT Web Sitesi Onay Maili',
      //   'token': verificationToken,
      //   'link': verificationLink,
      // });
    } catch (e) {
      // Email gönderilemese bile devam et (geliştirme aşamasında)
      print('⚠️  Email gönderme hatası (geliştirme modu): $e');
      // Production'da bu hatayı throw edin:
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
}

