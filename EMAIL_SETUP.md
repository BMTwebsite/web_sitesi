# Email Onay Sistemi Kurulumu

Bu doküman, admin kayıt sistemi için email onay mekanizmasının nasıl kurulacağını açıklar.

## Özellikler

- ✅ Admin kayıt sayfası (@bmt.edu.tr email kontrolü)
- ✅ Email onay sistemi (bmt.edu.tr adresine gönderim)
- ✅ Onay linki ile hesap aktivasyonu
- ✅ Spam'a gitmemesi için doğru email ayarları
- ✅ Email başlığı: "BMT Web Sitesi Onay Maili"

## Kurulum Adımları

### 1. Firebase Cloud Functions Kurulumu

#### Gereksinimler
- Node.js 18+ yüklü olmalı
- Firebase CLI yüklü olmalı: `npm install -g firebase-tools`

#### Adımlar

1. **Firebase'e giriş yapın:**
   ```bash
   firebase login
   ```

2. **Firebase Functions'ı başlatın:**
   ```bash
   firebase init functions
   ```
   - JavaScript seçin
   - ESLint kullanmak isteyip istemediğinizi seçin
   - Dependencies'i şimdi yükleyin

3. **Functions klasörüne gidin:**
   ```bash
   cd functions
   ```

4. **Gerekli paketleri yükleyin:**
   ```bash
   npm install nodemailer
   ```

5. **`functions/index.js` dosyasını düzenleyin:**
   - `your-email@gmail.com` yerine BMT email adresinizi yazın
   - Gmail App Password oluşturun (veya OAuth2 kullanın)

6. **Deploy edin:**
   ```bash
   firebase deploy --only functions
   ```

### 2. Gmail App Password Oluşturma

1. Google Hesabınıza gidin
2. Güvenlik > 2 Adımlı Doğrulama'yı etkinleştirin
3. Uygulama şifreleri > Uygulama seçin > "Mail" seçin
4. Oluşturulan şifreyi kopyalayın
5. `functions/index.js` dosyasındaki `pass` alanına yapıştırın

### 3. Email Servisini Aktifleştirme

`lib/services/email_service.dart` dosyasında:

1. Firebase Cloud Functions URL'ini güncelleyin:
   ```dart
   final url = 'https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/sendVerificationEmail';
   ```

2. Email gönderme kodunu aktifleştirin (şu anda comment'li)

### 4. Email Ayarları (Spam'a Gitmemesi İçin)

#### SPF Kaydı
Domain'iniz için SPF kaydı ekleyin:
```
v=spf1 include:_spf.google.com ~all
```

#### DKIM Kaydı
Gmail kullanıyorsanız, Google Workspace'de DKIM'i etkinleştirin.

#### DMARC Kaydı
```
v=DMARC1; p=none; rua=mailto:admin@bmt.edu.tr
```

#### Email İçeriği
- `functions/index.js` dosyasında email içeriği HTML formatında
- Profesyonel görünüm
- Doğru "From" adresi: "BMT Web Sitesi" <your-email@bmt.edu.tr>
- Email başlığı: "BMT Web Sitesi Onay Maili"

### 5. Test Etme

1. Admin kayıt sayfasına gidin
2. @bmt.edu.tr ile biten bir email girin
3. Kayıt olun
4. Email'inizi kontrol edin (Spam klasörüne de bakın)
5. Onay linkine tıklayın
6. Giriş yapmayı deneyin

## Alternatif: SendGrid veya Mailgun Kullanımı

Gmail yerine SendGrid veya Mailgun gibi profesyonel email servisleri kullanabilirsiniz:

### SendGrid Örneği

```javascript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

const msg = {
  to: to,
  from: 'noreply@bmt.edu.tr',
  subject: 'BMT Web Sitesi Onay Maili',
  html: emailHtml,
};

await sgMail.send(msg);
```

### Mailgun Örneği

```javascript
const formData = require('form-data');
const Mailgun = require('mailgun.js');
const mailgun = new Mailgun(formData);

const mg = mailgun.client({
  username: 'api',
  key: process.env.MAILGUN_API_KEY,
});

await mg.messages.create('bmt.edu.tr', {
  from: 'BMT Web Sitesi <noreply@bmt.edu.tr>',
  to: [to],
  subject: 'BMT Web Sitesi Onay Maili',
  html: emailHtml,
});
```

## Sorun Giderme

### Email Spam'a Gidiyor
- SPF, DKIM, DMARC kayıtlarını kontrol edin
- "From" adresinin doğru olduğundan emin olun
- Email içeriğinde spam kelimeler kullanmayın
- Link'lerin HTTPS olduğundan emin olun

### Email Gönderilmiyor
- Firebase Cloud Functions loglarını kontrol edin: `firebase functions:log`
- Gmail App Password'un doğru olduğundan emin olun
- Firestore'da `pending_admins` koleksiyonunu kontrol edin

### Onay Linki Çalışmıyor
- URL'nin doğru olduğundan emin olun
- Token'ın Firestore'da mevcut olduğunu kontrol edin
- Token'ın daha önce kullanılmadığından emin olun

## Güvenlik Notları

- Şifreleri Firestore'da saklamayın (şu anda geçici olarak saklanıyor, production'da hash'leyin)
- Token'ları 24 saat sonra expire edin
- Rate limiting ekleyin (çok fazla kayıt denemelerini engelleyin)
- Email doğrulama için reCAPTCHA ekleyin

