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
      print('🔑 Token: $verificationToken');
      
      // Firebase Cloud Functions'ı çağır
      final functions = FirebaseFunctions.instance;
      print('🔧 Firebase Functions instance oluşturuldu');
      
      final callable = functions.httpsCallable(
        'sendVerificationEmail',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60), // 60 saniye timeout (artırıldı)
        ),
      );
      print('✅ Callable function hazır');
      
      print('📤 Cloud Function çağrılıyor...');
      final result = await callable.call({
        'to': verificationEmailAddress, // Onay maili bu adrese gidecek
        'userEmail': toEmail, // Kullanıcının email'i (email içeriğinde gösterilecek)
        'subject': 'BMT Web Sitesi Onay Maili',
        'token': verificationToken,
        'link': verificationLink,
      }).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏱️ Timeout: Cloud Function 60 saniye içinde yanıt vermedi');
          throw 'E-posta gönderme işlemi zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.';
        },
      );
      
      print('📥 Cloud Function yanıtı alındı: ${result.data}');
      print('📊 Result data type: ${result.data.runtimeType}');
      
      if (result.data == null) {
        print('⚠️ Result data null');
        throw 'E-posta gönderme yanıtı alınamadı.';
      }
      
      // Result data bir Map olabilir veya direkt success değeri olabilir
      final success = result.data is Map 
          ? (result.data as Map)['success'] 
          : result.data;
      
      print('✅ Success değeri: $success');
      
      if (success != true) {
        print('❌ Success false veya null');
        final errorMsg = result.data is Map 
            ? (result.data as Map)['error'] ?? 'Bilinmeyen hata'
            : 'E-posta gönderilemedi';
        throw 'E-posta gönderilemedi: $errorMsg';
      }
      
      print('✅ E-posta başarıyla kuyruğa eklendi');
    } catch (e, stackTrace) {
      print('❌ E-posta gönderme hatası: $e');
      print('📚 Stack trace: $stackTrace');
      
      // Daha detaylı hata mesajı
      String errorMessage = 'E-posta gönderilirken hata oluştu.';
      
      if (e.toString().contains('timeout') || e.toString().contains('zaman aşımı')) {
        errorMessage = 'E-posta gönderme işlemi zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.';
      } else if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'E-posta gönderme izni yok. Firebase Cloud Functions izinlerini kontrol edin.';
      } else if (e.toString().contains('not-found') || e.toString().contains('NOT_FOUND')) {
        errorMessage = 'E-posta gönderme fonksiyonu bulunamadı. Lütfen Cloud Functions\'ı deploy edin.';
      } else if (e.toString().contains('unavailable') || e.toString().contains('UNAVAILABLE')) {
        errorMessage = 'E-posta servisi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      } else {
        errorMessage = 'E-posta gönderilirken hata oluştu: ${e.toString()}';
      }
      
      throw errorMessage;
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

