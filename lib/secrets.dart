/// Firebase yapılandırma bilgileri
/// 
/// Bu dosya git'e eklenmemelidir.
/// secrets.dart.example dosyasını kopyalayıp secrets.dart olarak kaydedin
/// ve Firebase Console'dan aldığınız bilgileri buraya ekleyin.

class Secrets {
  // Firebase Web Config
  static const String firebaseApiKey = "AIzaSyCB-KoygZg0p2T5XeCz4L2Iha7cy9MJ_Fk";
  static const String firebaseAuthDomain = "bmt-web-41790.firebaseapp.com";
  static const String firebaseProjectId = "bmt-web-41790";
  static const String firebaseStorageBucket = "bmt-web-41790.firebasestorage.app";
  static const String firebaseMessagingSenderId = "136238539718";
  static const String firebaseAppId = "1:136238539718:web:83bc685db7378e964648c7";
  
  // Onay maili gönderilecek email adresi
  // Kayıt olan kullanıcılar için onay isteği bu adrese gönderilecek
  static const String verificationEmailTo = "suheyla0403@gmail.com";
  
  // Gmail App Password - E-posta göndermek için kullanılır
  // Gmail App Password oluşturma: https://myaccount.google.com/apppasswords
  // NOT: Bu değer functions/.env dosyasına da eklenmelidir
  // Production için: firebase functions:secrets:set GMAIL_APP_PASSWORD
  static const String gmailAppPassword = "YOUR_GMAIL_APP_PASSWORD_HERE";
}
