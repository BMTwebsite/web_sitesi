# Firebase Kurulum ve Rules Rehberi - Kapsamlı Kılavuz

Bu doküman, Firebase kurulumu ve Firestore Security Rules yapılandırması için tüm gerekli bilgileri içermektedir.

---

## 📋 İçindekiler

1. [Firebase Projesi Oluşturma ve Yapılandırma](#1-firebase-projesi-oluşturma-ve-yapılandırma)
2. [Firestore Security Rules](#2-firestore-security-rules)
3. [Hızlı Çözüm (En Basit Yöntem)](#3-hızlı-çözüm-en-basit-yöntem)
4. [Rules Deploy Yöntemleri](#4-rules-deploy-yöntemleri)
5. [Sorun Giderme](#5-sorun-giderme)
6. [Test Mode Kullanımı](#6-test-mode-kullanımı)

---

## 1. Firebase Projesi Oluşturma ve Yapılandırma

### 1.1 Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Add project" (Proje Ekle) butonuna tıklayın
3. Proje adını girin: **bmt-web-41790**
4. Google Analytics'i isteğe bağlı olarak etkinleştirin
5. Projeyi oluşturun

### 1.2 Web Uygulaması Ekleme

1. Firebase Console'da projenizi seçin
2. Sol menüden "Project settings" (Proje ayarları) ikonuna tıklayın
3. Aşağı kaydırın ve "Your apps" (Uygulamalarınız) bölümünde web ikonuna (</>) tıklayın
4. Uygulama adını girin (örn: "BMT Web")
5. "Register app" (Uygulamayı kaydet) butonuna tıklayın
6. Firebase yapılandırma bilgilerinizi kopyalayın

### 1.3 Firebase Yapılandırmasını Ekleme

Firebase API anahtarları güvenlik için ayrı dosyalarda saklanmaktadır ve git'e eklenmemektedir.

#### lib/secrets.dart Dosyasını Oluşturma

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

#### web/secrets.js Dosyasını Oluşturma

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

### 1.4 Firebase Authentication Kurulumu

1. Firebase Console'da sol menüden "Authentication" (Kimlik Doğrulama) seçin
2. "Get started" (Başlayın) butonuna tıklayın
3. "Sign-in method" (Giriş yöntemi) sekmesine gidin
4. "Email/Password" (E-posta/Şifre) seçeneğini etkinleştirin
5. "Save" (Kaydet) butonuna tıklayın

### 1.5 Admin Kullanıcı Oluşturma

1. Firebase Console'da "Authentication" > "Users" (Kullanıcılar) sekmesine gidin
2. "Add user" (Kullanıcı ekle) butonuna tıklayın
3. E-posta adresini `admin@bmt.edu.tr` olarak girin
4. Şifre belirleyin (en az 6 karakter)
5. "Add user" (Kullanıcı ekle) butonuna tıklayın

**Not:** Admin e-posta adresi `lib/secrets.dart` dosyasında `adminEmail` olarak tanımlanmıştır. Farklı bir e-posta kullanmak isterseniz `secrets.dart` dosyasını güncelleyin.

### 1.6 Firestore Database Kurulumu

1. Firebase Console'da sol menüden "Firestore Database" seçin
2. "Create database" (Veritabanı oluştur) butonuna tıklayın
3. "Start in test mode" (Test modunda başlat) seçeneğini seçin (geliştirme için)
4. Veritabanı konumunu seçin
5. "Enable" (Etkinleştir) butonuna tıklayın

---

## 2. Firestore Security Rules

### 2.1 Önerilen Production Rules (Güvenli)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Pending Admins - herkes kayıt olabilir, authenticated kullanıcılar yönetebilir
    match /pending_admins/{pendingId} {
      allow create: if true; // Herkes kayıt olabilir
      allow read, update, delete: if request.auth != null; // Authenticated kullanıcılar yönetebilir
    }
    
    // Events koleksiyonu - herkes okuyabilir, authenticated kullanıcılar yazabilir
    match /events/{eventId} {
      allow read: if true; // Herkes okuyabilir
      allow write: if request.auth != null; // Authenticated kullanıcılar yazabilir
    }
    
    // Admins - authenticated kullanıcılar okuyabilir/yazabilir
    match /admins/{adminId} {
      allow read, write: if request.auth != null; // Authenticated kullanıcılar yönetebilir
    }
  }
}
```

### 2.2 Test Rules (Geçici - Sadece Geliştirme İçin)

⚠️ **UYARI:** Bu kurallar geçici olarak HERKESE izin verir. Sadece test için kullanın, production'da yukarıdaki güvenli kuralları kullanmalısınız.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pending_admins/{document=**} {
      allow read, write: if true;
    }
    match /events/{document=**} {
      allow read, write: if true;
    }
    match /admins/{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 3. Hızlı Çözüm (En Basit Yöntem)

### 3.1 Firestore Timeout Hatası Çözümü

Eğer "Kayıt işlemi zaman aşımına uğradı" hatası alıyorsanız:

### Adım 1: Firebase Console'a Gidin
👉 https://console.firebase.google.com/project/bmt-web-41790/firestore/rules

### Adım 2: Mevcut Kuralları Silin
- Rules editöründe TÜM metni seçin (Ctrl+A)
- Delete tuşuna basın

### Adım 3: Yeni Kuralları Yapıştırın

**Geliştirme İçin (Test):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pending_admins/{document=**} {
      allow read, write: if true;
    }
    match /events/{document=**} {
      allow read, write: if true;
    }
    match /admins/{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Production İçin (Güvenli):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pending_admins/{pendingId} {
      allow create: if true;
      allow read, update, delete: if request.auth != null;
    }
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /admins/{adminId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Adım 4: Publish Butonuna Tıklayın
- Sağ üstteki **"Publish"** butonuna tıklayın
- Onaylayın

### Adım 5: Bekleyin
- 10-30 saniye bekleyin
- Rules sekmesinde "Published" yazısını kontrol edin

### Adım 6: Uygulamayı Yeniden Başlatın
- Flutter uygulamasında **R** tuşuna basın (hot restart)
- Veya uygulamayı kapatıp açın

---

## 4. Rules Deploy Yöntemleri

### 4.1 Yöntem 1: Firebase Console'dan Manuel (Önerilen - Kolay)

1. Firebase Console'a gidin: https://console.firebase.google.com/project/bmt-web-41790/firestore/rules
2. Mevcut kuralları silin (Ctrl+A, Delete)
3. Yukarıdaki kurallardan birini yapıştırın
4. **Publish** butonuna tıklayın
5. 10-30 saniye bekleyin
6. Uygulamayı yeniden başlatın

### 4.2 Yöntem 2: Firebase CLI ile Deploy

#### Adım 1: Firebase'e Giriş Yapın
```bash
firebase login
```

#### Adım 2: Projeyi Bağlayın
```bash
firebase use bmt-web-41790
```

#### Adım 3: Rules Dosyasını Oluşturun

`firestore.rules` dosyasını oluşturun ve yukarıdaki kurallardan birini ekleyin.

#### Adım 4: firebase.json Dosyasını Yapılandırın

```json
{
  "firestore": {
    "rules": "firestore.rules"
  }
}
```

#### Adım 5: Rules'ı Deploy Edin
```bash
firebase deploy --only firestore:rules
```

---

## 5. Sorun Giderme

### 5.1 Rules Görünmüyor?

1. Tarayıcıyı yenileyin (Ctrl+F5)
2. Farklı bir tarayıcı deneyin
3. Rules sekmesinde "Published" yazısını kontrol edin

### 5.2 Hala Timeout Hatası Alıyorum

1. **Firebase Console'da Rules'ı kontrol edin:**
   - Rules sekmesinde doğru kuralların olduğundan emin olun
   - **Publish** butonuna tıkladığınızdan emin olun
   - "Published" yazısını görüyorsanız kurallar yayınlanmıştır

2. **Firestore Mode'unu kontrol edin:**
   - Firestore Database > Overview
   - Native mode'da olmalı (Test mode değil)
   - Eğer Test mode'daysa, 30 gün içinde herkes yazabilir

3. **Tarayıcı konsolunu kontrol edin:**
   - F12 tuşuna basın
   - Console sekmesine gidin
   - Kırmızı hata mesajlarını kontrol edin
   - Network sekmesinde Firebase isteklerini kontrol edin

4. **İnternet bağlantısını kontrol edin:**
   - Firebase servislerinin erişilebilir olduğundan emin olun

5. **Firebase proje ayarlarını kontrol edin:**
   - Firebase Console > Project Settings
   - Firestore'un aktif olduğundan emin olun

### 5.3 Hata Mesajlarını Kontrol Etme

1. Tarayıcı konsolunu açın (F12)
2. Console sekmesine gidin
3. Kırmızı hata mesajlarını kontrol edin
4. Network sekmesinde Firebase isteklerini kontrol edin
5. Hata mesajlarını not edin ve düzeltin

### 5.4 Kontrol Listesi

- [ ] Firebase Console'da Rules sekmesine gittim
- [ ] Mevcut kuralları sildim
- [ ] Yukarıdaki kuralları yapıştırdım
- [ ] **Publish** butonuna tıkladım
- [ ] 30 saniye bekledim
- [ ] Uygulamayı yeniden başlattım (hot restart)
- [ ] Tekrar denedim
- [ ] Tarayıcı konsolunda hata mesajı kontrol ettim

---

## 6. Test Mode Kullanımı

### 6.1 Test Mode Nedir?

Test Mode, Firestore'u 30 gün boyunca herkesin yazabileceği şekilde yapılandırır. Rules ayarlamaya gerek yoktur.

### 6.2 Test Mode'u Aktifleştirme

1. Firebase Console'a gidin: https://console.firebase.google.com/project/bmt-web-41790/firestore/database
2. Firestore Database sayfasında
3. Eğer "Native mode" görüyorsanız, **"Test mode"** seçeneğini bulun
4. Test mode'u seçin ve onaylayın

### 6.3 Test Mode Özellikleri

- ✅ 30 gün boyunca **herkes** Firestore'a yazabilir
- ✅ Rules ayarlamaya gerek yok
- ✅ Hemen çalışır

### 6.4 Test Mode Kısıtlamaları

- ⚠️ Test mode **30 gün** geçerlidir
- ⚠️ 30 gün sonra rules ayarlamanız gerekir
- ⚠️ Production için rules ayarlamalısınız

---

## 7. Production İçin Güvenlik

Production'da daha sıkı kurallar kullanmanız önerilir:

```javascript
match /pending_admins/{pendingId} {
  allow read: if request.auth != null && 
    request.auth.token.email.matches('.*@bmt\\.edu\\.tr$');
  allow create: if request.resource.data.email is string &&
    request.resource.data.email.matches('.*@.*');
  allow update, delete: if false; // Sadece sistem güncelleyebilir
}

match /events/{eventId} {
  allow read: if true;
  allow write: if request.auth != null && 
    request.auth.token.email.matches('.*@bmt\\.edu\\.tr$');
}

match /admins/{adminId} {
  allow read, write: if request.auth != null && 
    request.auth.token.email == 'admin@bmt.edu.tr';
}
```

---

## 8. Projeyi Çalıştırma

Tüm yapılandırmaları tamamladıktan sonra:

```bash
flutter pub get
flutter run -d chrome
```

---

## 📝 Önemli Notlar

- **Güvenlik:** Firebase API anahtarları `lib/secrets.dart` ve `web/secrets.js` dosyalarında saklanmaktadır. Bu dosyalar `.gitignore`'da olduğu için git'e eklenmez.
- **Admin e-posta adresi:** `lib/secrets.dart` dosyasındaki `adminEmail` değişkeninden alınır (varsayılan: `admin@bmt.edu.tr`)
- **Firestore koleksiyonları:** 
  - `events` - Etkinlikler
  - `pending_admins` - Bekleyen admin kayıtları
  - `admins` - Onaylanmış adminler
- **Test Rules vs Production Rules:** Geliştirme aşamasında test rules kullanabilirsiniz, ancak production'a geçmeden önce güvenli rules ayarlayın.
- Tüm etkinlik verileri Firestore'da saklanır
- Admin panelinden etkinlik ekleme, düzenleme ve silme işlemleri yapılabilir

---

## 🔗 Faydalı Bağlantılar

- Firebase Console: https://console.firebase.google.com/project/bmt-web-41790
- Firestore Rules: https://console.firebase.google.com/project/bmt-web-41790/firestore/rules
- Firebase Dokümantasyonu: https://firebase.google.com/docs

---

## 📸 Ekran Görüntüsü Kontrolü

Rules sekmesinde şöyle görünmeli:
- ✅ Sol tarafta rules editörü
- ✅ Sağ üstte "Publish" butonu
- ✅ Yukarıdaki kurallar yazılı
- ✅ "Publish" butonuna tıkladıktan sonra "Published" yazısı görünmeli

Eğer farklı bir şey görüyorsanız, ekran görüntüsü paylaşın.

---

**Son Güncelleme:** Tüm Firebase Rules dosyaları birleştirildi ve bu kapsamlı rehber oluşturuldu.

