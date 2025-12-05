# Hızlı Email Kurulum Rehberi

Email göndermek için Firebase Cloud Functions kurulumu gereklidir. İşte adım adım kurulum:

## Seçenek 1: Firebase Cloud Functions (Önerilen)

### Adım 1: Node.js ve Firebase CLI Kurulumu

1. **Node.js yükleyin:** https://nodejs.org/ (v18 veya üzeri)
2. **Firebase CLI yükleyin:**
   ```bash
   npm install -g firebase-tools
   ```

### Adım 2: Firebase'e Giriş

```bash
firebase login
```

### Adım 3: Functions Klasörünü Hazırla

```bash
cd functions
npm install
```

### Adım 4: Gmail Ayarları

1. **Gmail hesabınızda 2 Adımlı Doğrulama'yı açın:**
   - Google Hesabı > Güvenlik > 2 Adımlı Doğrulama

2. **Uygulama Şifresi oluşturun:**
   - Google Hesabı > Güvenlik > Uygulama şifreleri
   - Uygulama seçin: "Mail"
   - Cihaz seçin: "Diğer (Özel ad)"
   - Oluşturulan 16 haneli şifreyi kopyalayın

### Adım 5: functions/index.js Dosyasını Güncelle

`functions/index.js` dosyasında şu satırları bulun ve güncelleyin:

```javascript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'bmtbanu@gmail.com', // Buraya email adresinizi yazın
    pass: 'xxxx xxxx xxxx xxxx', // Buraya uygulama şifresini yazın
  },
});
```

Ve:

```javascript
from: '"BMT Web Sitesi" <bmtbanu@gmail.com>', // Buraya email adresinizi yazın
```

### Adım 6: Deploy Et

```bash
firebase deploy --only functions
```

Deploy işlemi tamamlandıktan sonra bir URL alacaksınız, örneğin:
```
https://us-central1-bmt-web-41790.cloudfunctions.net/sendVerificationEmail
```

### Adım 7: Flutter Kodunu Aktifleştir

`lib/services/email_service.dart` dosyasını açın ve şu kısmı bulun:

```dart
// TODO: Firebase Cloud Functions deploy edildikten sonra bu kodu aktifleştirin
// final functions = FirebaseFunctions.instance;
// final callable = functions.httpsCallable('sendVerificationEmail');
// await callable.call({
//   'to': verificationEmailAddress,
//   'userEmail': toEmail,
//   'subject': 'BMT Web Sitesi Onay Maili',
//   'token': verificationToken,
//   'link': verificationLink,
// });
```

Bu kodu şu şekilde değiştirin:

```dart
import 'package:cloud_functions/cloud_functions.dart';

// ...

final functions = FirebaseFunctions.instance;
final callable = functions.httpsCallable('sendVerificationEmail');
await callable.call({
  'to': verificationEmailAddress,
  'userEmail': toEmail,
  'subject': 'BMT Web Sitesi Onay Maili',
  'token': verificationToken,
  'link': verificationLink,
});
```

**Önemli:** `pubspec.yaml` dosyasına `cloud_functions` paketini eklemeniz gerekiyor:

```yaml
dependencies:
  cloud_functions: ^5.0.0
```

Sonra:
```bash
flutter pub get
```

## Seçenek 2: EmailJS (Daha Basit, Ücretsiz)

EmailJS kullanarak daha basit bir çözüm:

1. **EmailJS'e kaydolun:** https://www.emailjs.com/
2. **Email servisi ekleyin** (Gmail)
3. **Template oluşturun**
4. **API key alın**
5. **Flutter kodunu güncelleyin**

Detaylar için: https://www.emailjs.com/docs/

## Test Etme

1. Admin kayıt sayfasına gidin
2. Bir email ile kayıt olun
3. `bmtbanu@gmail.com` adresine email gelmeli
4. Email'deki onay linkine tıklayın
5. Hesap aktifleşir

## Sorun Giderme

### Email gelmiyor
- Firebase Functions loglarını kontrol edin: `firebase functions:log`
- Gmail App Password'un doğru olduğundan emin olun
- Spam klasörünü kontrol edin

### Functions deploy hatası
- Node.js versiyonunu kontrol edin (v18+)
- `functions/package.json` dosyasını kontrol edin
- `npm install` komutunu tekrar çalıştırın

