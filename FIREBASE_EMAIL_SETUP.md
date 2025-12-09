# Firebase Extensions - Trigger Email Kurulumu

Bu sistem **tamamen Firebase üzerinden** çalışır. Kodda şifre/API key yok! Tüm ayarlar Firebase Console'dan yapılır.

## Avantajlar

✅ **Tamamen Firebase üzerinden** - Kodda şifre/API key yok  
✅ **Güvenli** - API key'ler Firebase Console'da saklanır  
✅ **Kolay kurulum** - Firebase Console'dan extension kurulumu  
✅ **Otomatik** - Firestore'a doküman eklenince otomatik e-posta gönderir  

## Kurulum Adımları

### 1. Firebase Extensions - Trigger Email Kurulumu

1. **Firebase Console'a gidin**: https://console.firebase.google.com
2. Projenizi seçin: `bmt-web-41790`
3. Sol menüden **Extensions** sekmesine tıklayın
4. **"Explore Extensions Hub"** turuncu butonuna tıklayın (sağ üstte)
   - Veya sayfada direkt **"Trigger Email"** arayın (arama kutusu varsa)
5. Açılan sayfada **"Trigger Email"** arayın
6. **Trigger Email** extension'ını bulun ve seçin
7. **Install** butonuna tıklayın

### 2. Extension Ayarları

Extension kurulumunda şunları seçin:

- **Email provider**: SendGrid veya Mailgun (SendGrid önerilir - ücretsiz plan var)
- **SendGrid API Key**: SendGrid'den API key alın (https://sendgrid.com - ücretsiz kayıt)
- **Default FROM email**: `suheyla0403@gmail.com` veya doğrulanmış e-posta adresi
- **Default FROM name**: `BMT Web Sitesi`
- **Default REPLY-TO email**: `suheyla0403@gmail.com`

### 3. SendGrid Kurulumu (Eğer SendGrid seçtiyseniz)

1. **SendGrid'e kayıt olun**: https://sendgrid.com (ücretsiz)
2. **API Key oluşturun**:
   - SendGrid Dashboard > Settings > API Keys
   - Create API Key
   - İsim: "Firebase Functions"
   - Permissions: "Full Access" veya sadece "Mail Send"
   - API Key'i kopyalayın
3. **Extension kurulumunda API Key'i yapıştırın**

### 4. Functions Deploy

```bash
cd functions
npm install
cd ..
firebase deploy --only "functions"
```

## Nasıl Çalışır?

1. Admin kayıt sayfasından kayıt olunur
2. `sendVerificationEmail` Cloud Function çağrılır
3. Function, Firestore'da `mail` koleksiyonuna bir doküman ekler
4. **Firebase Extensions - Trigger Email** bu dokümanı görür
5. Extension otomatik olarak e-posta gönderir
6. E-posta `suheyla0403@gmail.com` adresine gider

## Kullanım

Artık admin kayıt sayfasından kayıt olduğunuzda, e-posta otomatik olarak gönderilecektir.

## Güvenlik

⚠️ **ÖNEMLİ:**
- API key'ler Firebase Console'da saklanır (kodda yok)
- Extension ayarları Firebase Console'dan yönetilir
- Kodda hiçbir şifre/API key bulunmaz

## Sorun Giderme

### E-posta gönderilmiyor

1. Firebase Console > Extensions > Trigger Email > Logs kontrol edin
2. Firestore'da `mail` koleksiyonunu kontrol edin (doküman eklendi mi?)
3. SendGrid/Mailgun dashboard'unda gönderim durumunu kontrol edin

### Extension kurulumu başarısız

1. Firebase Blaze planına geçtiğinizden emin olun
2. SendGrid/Mailgun API key'in doğru olduğundan emin olun
3. Extension loglarını kontrol edin

## Limitler

- **SendGrid ücretsiz**: 100 email/gün
- **Mailgun ücretsiz**: 5000 email/ay (ilk 3 ay)

## İletişim

Sorun yaşarsanız:
- Firebase Console > Extensions > Trigger Email > Logs
- SendGrid/Mailgun Dashboard > Activity
