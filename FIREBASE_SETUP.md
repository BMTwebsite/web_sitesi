# Firebase Kurulum Talimatları

Bu proje Firebase Authentication ve Firestore kullanmaktadır. Projeyi çalıştırmadan önce Firebase'i yapılandırmanız gerekmektedir.

## 1. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Add project" (Proje Ekle) butonuna tıklayın
3. Proje adını girin ve devam edin
4. Google Analytics'i isteğe bağlı olarak etkinleştirin
5. Projeyi oluşturun

## 2. Web Uygulaması Ekleme

1. Firebase Console'da projenizi seçin
2. Sol menüden "Project settings" (Proje ayarları) ikonuna tıklayın
3. Aşağı kaydırın ve "Your apps" (Uygulamalarınız) bölümünde web ikonuna (</>) tıklayın
4. Uygulama adını girin (örn: "BMT Web")
5. "Register app" (Uygulamayı kaydet) butonuna tıklayın
6. Firebase yapılandırma bilgilerinizi kopyalayın

## 3. Firebase Yapılandırmasını Ekleme

Firebase API anahtarları güvenlik için ayrı dosyalarda saklanmaktadır ve git'e eklenmemektedir.

### lib/secrets.dart Dosyasını Oluşturma

1. `lib/secrets.dart.example` dosyasını kopyalayın
2. `lib/secrets.dart` olarak kaydedin
3. Firebase Console'dan aldığınız bilgileri buraya ekleyin:

```dart
class Secrets {
  static const String firebaseApiKey = "YOUR_API_KEY";
  static const String firebaseAuthDomain = "YOUR_AUTH_DOMAIN";
  static const String firebaseProjectId = "YOUR_PROJECT_ID";
  static const String firebaseStorageBucket = "YOUR_STORAGE_BUCKET";
  static const String firebaseMessagingSenderId = "YOUR_MESSAGING_SENDER_ID";
  static const String firebaseAppId = "YOUR_APP_ID";
  static const String adminEmail = "admin@bmt.edu.tr";
}
```

**Not:** `secrets.dart` dosyası `.gitignore`'da olduğu için git'e eklenmeyecektir.

### web/secrets.js Dosyasını Oluşturma

1. `web/secrets.js.example` dosyasını kopyalayın
2. `web/secrets.js` olarak kaydedin
3. Firebase Console'dan aldığınız bilgileri buraya ekleyin:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};
```

**Not:** `secrets.js` dosyası da `.gitignore`'da olduğu için git'e eklenmeyecektir.

## 4. Firebase Authentication Kurulumu

1. Firebase Console'da sol menüden "Authentication" (Kimlik Doğrulama) seçin
2. "Get started" (Başlayın) butonuna tıklayın
3. "Sign-in method" (Giriş yöntemi) sekmesine gidin
4. "Email/Password" (E-posta/Şifre) seçeneğini etkinleştirin
5. "Save" (Kaydet) butonuna tıklayın

## 5. Admin Kullanıcı Oluşturma

1. Firebase Console'da "Authentication" > "Users" (Kullanıcılar) sekmesine gidin
2. "Add user" (Kullanıcı ekle) butonuna tıklayın
3. E-posta adresini `admin@bmt.edu.tr` olarak girin
4. Şifre belirleyin (en az 6 karakter)
5. "Add user" (Kullanıcı ekle) butonuna tıklayın

**Not:** Admin e-posta adresi `lib/secrets.dart` dosyasında `adminEmail` olarak tanımlanmıştır. Farklı bir e-posta kullanmak isterseniz `secrets.dart` dosyasını güncelleyin.

## 6. Firestore Database Kurulumu

1. Firebase Console'da sol menüden "Firestore Database" seçin
2. "Create database" (Veritabanı oluştur) butonuna tıklayın
3. "Start in test mode" (Test modunda başlat) seçeneğini seçin (geliştirme için)
4. Veritabanı konumunu seçin
5. "Enable" (Etkinleştir) butonuna tıklayın

### Firestore Güvenlik Kuralları (Önemli!)

Geliştirme aşamasından sonra Firestore güvenlik kurallarını güncellemeniz önerilir:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events koleksiyonu - herkes okuyabilir, sadece admin yazabilir
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.email == 'admin@bmt.edu.tr';
    }
  }
}
```

## 7. Projeyi Çalıştırma

Tüm yapılandırmaları tamamladıktan sonra:

```bash
flutter pub get
flutter run -d chrome
```

## Önemli Notlar

- **Güvenlik:** Firebase API anahtarları `lib/secrets.dart` ve `web/secrets.js` dosyalarında saklanmaktadır. Bu dosyalar `.gitignore`'da olduğu için git'e eklenmez.
- Admin e-posta adresi: `lib/secrets.dart` dosyasındaki `adminEmail` değişkeninden alınır (varsayılan: `admin@bmt.edu.tr`)
- Firestore koleksiyon adı: `events`
- Tüm etkinlik verileri Firestore'da saklanır
- Admin panelinden etkinlik ekleme, düzenleme ve silme işlemleri yapılabilir

## Sorun Giderme

- `lib/secrets.dart` ve `web/secrets.js` dosyalarının oluşturulduğundan ve doğru bilgilerle doldurulduğundan emin olun
- Firebase yapılandırma bilgilerinin doğru olduğundan emin olun
- Firebase Console'da Authentication ve Firestore'un etkin olduğunu kontrol edin
- Tarayıcı konsolunda hata mesajlarını kontrol edin
- Admin kullanıcısının doğru e-posta adresiyle oluşturulduğundan emin olun
- `secrets.dart` ve `secrets.js` dosyalarının `.gitignore`'da olduğunu kontrol edin

