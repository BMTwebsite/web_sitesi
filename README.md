# BMT Web Sitesi - Kapsamlı Kurulum Rehberi

Bilgisayar Mühendisliği Topluluğu web sitesi için tüm kurulum ve yapılandırma bilgileri.

---

## 📋 İçindekiler

1. [Proje Hakkında](#proje-hakkında)
2. [Hızlı Başlangıç](#hızlı-başlangıç)
3. [Firebase Kurulumu](#firebase-kurulumu)
4. [Firestore Kurulumu](#firestore-kurulumu)
5. [Email Sistemi Kurulumu](#email-sistemi-kurulumu)
6. [Admin Sistemi](#admin-sistemi)
7. [Site Ayarları](#site-ayarları)
8. [Sorun Giderme](#sorun-giderme)
9. [Yardımcı Scripts](#yardımcı-scripts)

---

## Proje Hakkında

Bu proje, Flutter Web kullanılarak geliştirilmiş bir topluluk web sitesidir. Firebase backend servisleri kullanılmaktadır.

### Özellikler

- ✅ Etkinlik yönetimi
- ✅ Admin paneli
- ✅ Email onay sistemi
- ✅ Site ayarları yönetimi
- ✅ İletişim bilgileri yönetimi

---

## Hızlı Başlangıç

### Gereksinimler

- Flutter SDK (3.8.1+)
- Node.js (20+)
- Firebase CLI
- Firebase Projesi (Blaze planı gerekli)

### Kurulum

```bash
# 1. Bağımlılıkları yükleyin
flutter pub get

# 2. Secrets dosyasını oluşturun
cp lib/secrets.dart.example lib/secrets.dart
# secrets.dart dosyasını düzenleyip Firebase bilgilerinizi ekleyin

# 3. Firebase'e giriş yapın
firebase login

# 4. Functions bağımlılıklarını yükleyin
cd functions
npm install
cd ..

# 5. Uygulamayı çalıştırın
flutter run -d chrome
```

---

## Firebase Kurulumu

### 1. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Add project" (Proje Ekle) butonuna tıklayın
3. Proje adını girin: `bmt-web-41790`
4. Google Analytics'i isteğe bağlı olarak etkinleştirin
5. Projeyi oluşturun

### 2. Web Uygulaması Ekleme

1. Firebase Console'da projenizi seçin
2. Sol menüden "Project settings" (⚙️) ikonuna tıklayın
3. "Your apps" bölümünde web ikonuna (</>) tıklayın
4. Uygulama adını girin (örn: "BMT Web")
5. "Register app" butonuna tıklayın
6. Firebase yapılandırma bilgilerinizi kopyalayın

### 3. Firebase Yapılandırmasını Ekleme

1. `lib/secrets.dart.example` dosyasını kopyalayın
2. `lib/secrets.dart` olarak kaydedin
3. Firebase Console'dan aldığınız bilgileri ekleyin:

```dart
class Secrets {
  static const String firebaseApiKey = "YOUR_API_KEY";
  static const String firebaseAuthDomain = "YOUR_AUTH_DOMAIN";
  static const String firebaseProjectId = "YOUR_PROJECT_ID";
  static const String firebaseStorageBucket = "YOUR_STORAGE_BUCKET";
  static const String firebaseMessagingSenderId = "YOUR_SENDER_ID";
  static const String firebaseAppId = "YOUR_APP_ID";
  
  static const String verificationEmailTo = "suheyla0403@gmail.com";
}
```

### 4. Firebase Blaze Planı

⚠️ **ÖNEMLİ:** Firebase Functions ve Extensions kullanmak için Blaze (pay-as-you-go) planına geçmeniz gerekir.

1. Firebase Console > Project Settings > Usage and billing
2. "Upgrade to Blaze" butonuna tıklayın
3. Ödeme bilgilerinizi ekleyin (ücretsiz kotanız var)

---

## Firestore Kurulumu

### 1. Firestore Security Rules

Firebase Console > Firestore Database > Rules sekmesine gidin ve aşağıdaki kuralları ekleyin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events koleksiyonu - herkes okuyabilir, sadece adminler yazabilir
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Pending Admins - herkes yazabilir (kayıt için)
    match /pending_admins/{pendingId} {
      allow read: if request.auth != null;
      allow write: if true;
      allow delete: if request.auth != null;
    }
    
    // Admins - sadece adminler okuyabilir/yazabilir
    match /admins/{adminId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Contact Settings - herkes okuyabilir, sadece adminler yazabilir
    match /contact_settings/{docId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Site Settings - herkes okuyabilir, sadece adminler yazabilir
    match /site_settings/{docId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Mail koleksiyonu - sadece Functions yazabilir
    match /mail/{mailId} {
      allow read: if request.auth != null;
      allow write: if false; // Sadece Functions yazabilir
    }
  }
}
```

Rules'ı **Publish** butonuna tıklayarak yayınlayın.

### 2. Firestore Koleksiyonları

Uygulama şu koleksiyonları kullanır:

#### `pending_admins`
Bekleyen admin kayıtları:
- `email` (string): Admin e-posta adresi
- `password` (string): Şifre
- `token` (string): Onay token'ı
- `createdAt` (timestamp): Oluşturulma tarihi

#### `admins`
Onaylanmış adminler:
- `email` (string): Admin e-posta adresi
- `createdAt` (timestamp): Oluşturulma tarihi

#### `events`
Etkinlikler:
- `type` (string): Etkinlik tipi
- `title` (string): Başlık
- `date` (string): Tarih
- `time` (string): Saat
- `location` (string): Konum
- `participants` (number): Katılımcı sayısı
- `colorHex` (string): Renk hex kodu

#### `contact_settings`
İletişim ayarları:
- `email` (string): İletişim e-postası
- `socialMedia` (array): Sosyal medya hesapları

#### `site_settings`
Site genel ayarları:
- `siteName` (string): Site adı
- `siteDescription` (string): Site açıklaması
- `email` (string): E-posta
- `phone` (string): Telefon
- `address` (string): Adres
- `copyright` (string): Telif hakkı metni

#### `mail`
Email kuyruğu (Firebase Extensions tarafından kullanılır):
- `to` (string): Alıcı e-posta
- `message` (object): Email içeriği

---

## Email Sistemi Kurulumu

### Firebase Extensions - Trigger Email (Önerilen)

Bu sistem **tamamen Firebase üzerinden** çalışır. Kodda şifre/API key yok!

#### Avantajlar

✅ **Tamamen Firebase üzerinden** - Kodda şifre/API key yok  
✅ **Güvenli** - API key'ler Firebase Console'da saklanır  
✅ **Kolay kurulum** - Firebase Console'dan extension kurulumu  
✅ **Otomatik** - Firestore'a doküman eklenince otomatik e-posta gönderir  

#### Kurulum Adımları

1. **Firebase Console'a gidin**: https://console.firebase.google.com
2. Projenizi seçin: `bmt-web-41790`
3. Sol menüden **Extensions** sekmesine tıklayın
4. **"Explore Extensions Hub"** turuncu butonuna tıklayın (sağ üstte)
5. Açılan sayfada **"Trigger Email"** arayın
6. **Trigger Email** extension'ını bulun ve seçin
7. **Install** butonuna tıklayın

#### Extension Ayarları

Extension kurulumunda şunları seçin:

- **Email provider**: SendGrid veya Mailgun (SendGrid önerilir - ücretsiz plan var)
- **SendGrid API Key**: SendGrid'den API key alın (https://sendgrid.com - ücretsiz kayıt)
- **Default FROM email**: `suheyla0403@gmail.com` veya doğrulanmış e-posta adresi
- **Default FROM name**: `BMT Web Sitesi`
- **Default REPLY-TO email**: `suheyla0403@gmail.com`

#### SendGrid Kurulumu

1. **SendGrid'e kayıt olun**: https://sendgrid.com (ücretsiz)
2. **API Key oluşturun**:
   - SendGrid Dashboard > Settings > API Keys
   - Create API Key
   - İsim: "Firebase Functions"
   - Permissions: "Full Access" veya sadece "Mail Send"
   - API Key'i kopyalayın
3. **Extension kurulumunda API Key'i yapıştırın**

#### Functions Deploy

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

#### Nasıl Çalışır?

1. Admin kayıt sayfasından kayıt olunur
2. `sendVerificationEmail` Cloud Function çağrılır
3. Function, Firestore'da `mail` koleksiyonuna bir doküman ekler
4. **Firebase Extensions - Trigger Email** bu dokümanı görür
5. Extension otomatik olarak e-posta gönderir
6. E-posta `suheyla0403@gmail.com` adresine gider

---

## Admin Sistemi

### Admin Kayıt İşlemi

1. Admin kayıt sayfasına gidin: `/admin-register`
2. E-posta ve şifre girin
3. Kayıt ol butonuna tıklayın
4. Onay e-postası gönderilir
5. E-postadaki onay linkine tıklayın
6. Hesap aktifleşir ve giriş yapabilirsiniz

### Özellikler

- ✅ Aynı e-posta için bekleyen kayıt varsa otomatik silinir
- ✅ Email gönderilemese bile kayıt başarılı sayılır
- ✅ Onay linki 24 saat geçerlidir

### Admin Paneli

Admin giriş yaptıktan sonra `/admin-panel` sayfasından:

- **Etkinlikler**: Etkinlik ekleme, düzenleme, silme
- **Site Ayarları**: Site adı, açıklama, iletişim bilgileri
- **İletişim Ayarları**: E-posta, sosyal medya hesapları
- **Bekleyen Onay Maillerini Sıfırla**: Tüm bekleyen kayıtları siler

---

## Site Ayarları

### Admin Panelinden Yönetim

Tüm site bilgileri admin panelinden yönetilir. Kodda hardcoded bilgi yoktur.

#### Site Ayarları Tab'ı

- Site adı
- Site açıklaması
- E-posta
- Telefon
- Adres
- Telif hakkı metni

#### İletişim Ayarları Tab'ı

- İletişim e-postası
- Sosyal medya hesapları (Instagram, LinkedIn, YouTube, TikTok)

---

## Sorun Giderme

### Sayfa Yüklenmiyor

1. Tarayıcı konsolunu açın (F12)
2. Hata mesajlarını kontrol edin
3. Firebase başlatma hatalarını kontrol edin
4. `lib/secrets.dart` dosyasının doğru olduğundan emin olun

### E-posta Gönderilmiyor

1. Firebase Console > Extensions > Trigger Email > Logs kontrol edin
2. Firestore'da `mail` koleksiyonunu kontrol edin (doküman eklendi mi?)
3. SendGrid/Mailgun dashboard'unda gönderim durumunu kontrol edin
4. Extension'ın kurulu olduğundan emin olun

### "Permission denied" Hatası

1. Firestore Security Rules'ı kontrol edin
2. Rules'ı **Publish** butonuna tıklayarak yayınlayın
3. Koleksiyon izinlerini kontrol edin

### Extension Kurulumu Başarısız

1. Firebase Blaze planına geçtiğinizden emin olun
2. SendGrid/Mailgun API key'in doğru olduğundan emin olun
3. Extension loglarını kontrol edin

### Timeout Hatası

1. İnternet bağlantınızı kontrol edin
2. Firebase servislerinin çalıştığından emin olun
3. Firestore quota limitlerini kontrol edin

### Font Yükleme Hatası

Font hatası sayfa yüklenmesini engellemez. Görmezden gelebilirsiniz. Sistem varsayılan fontunu kullanır.

---

## Yardımcı Scripts

### Bekleyen Admin Kayıtlarını Temizleme

Admin girişi olmadan bekleyen admin kayıtlarını silmek için:

#### Yöntem 1: Firebase Console (En Kolay)

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin: `bmt-web-41790`
3. Sol menüden **Firestore Database** > **Data** sekmesine gidin
4. `pending_admins` koleksiyonunu bulun
5. Koleksiyonun üzerine tıklayın
6. Tüm dokümanları seçin (Ctrl+A veya Cmd+A)
7. **Delete** butonuna tıklayın
8. Onaylayın

#### Yöntem 2: Node.js Script

```bash
cd scripts
npm install
node clear-pending-admins.js
```

Detaylı bilgi için: `scripts/README.md`

---

## Limitler

- **SendGrid ücretsiz**: 100 email/gün
- **Mailgun ücretsiz**: 5000 email/ay (ilk 3 ay)

---

## Güvenlik

⚠️ **ÖNEMLİ:**

- `lib/secrets.dart` dosyasını **ASLA** git'e eklemeyin!
- `web/secrets.js` dosyasını **ASLA** git'e eklemeyin!
- Service account key dosyalarını **ASLA** git'e eklemeyin!
- API key'ler Firebase Console'da saklanır (kodda yok)
- Extension ayarları Firebase Console'dan yönetilir
- Kodda hiçbir şifre/API key bulunmaz

---

## İletişim

Sorun yaşarsanız:

- Firebase Console > Extensions > Trigger Email > Logs
- SendGrid/Mailgun Dashboard > Activity
- Firebase Console > Functions > Logs

---

## Lisans

Bu proje özel bir projedir.
