# Gmail E-posta Gönderme Kurulumu

Bu doküman, Firebase Cloud Functions ile Gmail üzerinden e-posta göndermek için gerekli adımları açıklar.

## 1. Gmail App Password Oluşturma

Gmail'den e-posta göndermek için App Password (Uygulama Şifresi) oluşturmanız gerekir.

### Adımlar:

1. **Google Hesabınıza gidin**: https://myaccount.google.com
2. **Güvenlik** sekmesine gidin
3. **2 Adımlı Doğrulama**'yı etkinleştirin (eğer etkin değilse)
   - Bu zorunludur, App Password oluşturmak için 2 Adımlı Doğrulama aktif olmalıdır
4. **Uygulama şifreleri** bölümüne gidin
   - Veya direkt: https://myaccount.google.com/apppasswords
5. **Uygulama seçin**: "Mail" seçin
6. **Cihaz seçin**: "Diğer (Özel ad)" seçin ve "Firebase Functions" yazın
7. **Oluştur** butonuna tıklayın
8. **16 haneli şifreyi kopyalayın** (örnek: `abcd efgh ijkl mnop`)
   - Boşlukları kaldırarak kullanabilirsiniz: `abcdefghijklmnop`

## 2. Firebase Functions'a App Password Ekleme

Oluşturduğunuz App Password'ü Firebase Functions'a environment variable olarak ekleyin.

### Yöntem 1: Firebase Functions Config (Önerilen)

```bash
firebase functions:config:set gmail.app_password="YOUR_APP_PASSWORD"
```

**Örnek:**
```bash
firebase functions:config:set gmail.app_password="abcdefghijklmnop"
```

### Yöntem 2: Environment Variable (Local Development)

Local'de test ederken:

```bash
# Windows PowerShell
$env:GMAIL_APP_PASSWORD="abcdefghijklmnop"

# Windows CMD
set GMAIL_APP_PASSWORD=abcdefghijklmnop

# Linux/Mac
export GMAIL_APP_PASSWORD="abcdefghijklmnop"
```

### Yöntem 3: .env Dosyası (Local Development)

`functions` klasöründe `.env` dosyası oluşturun:

```
GMAIL_APP_PASSWORD=abcdefghijklmnop
```

**Not:** `.env` dosyasını `.gitignore`'a eklemeyi unutmayın!

## 3. Firebase Functions Deploy

Config'i ekledikten sonra Functions'ı deploy edin:

```bash
cd functions
npm install
firebase deploy --only functions
```

## 4. Test Etme

Deploy işlemi tamamlandıktan sonra, admin kayıt sayfasından bir kayıt denemesi yapın. E-posta `suheyla0403@gmail.com` adresine gönderilmelidir.

## Sorun Giderme

### "Gmail App Password ayarlanmamış" hatası alıyorsanız:

1. Firebase Functions config'in doğru ayarlandığından emin olun:
   ```bash
   firebase functions:config:get
   ```
   Çıktıda `gmail.app_password` görünmelidir.

2. Deploy işlemini tekrar yapın:
   ```bash
   firebase deploy --only functions
   ```

### "Invalid login" hatası alıyorsanız:

1. App Password'ün doğru kopyalandığından emin olun (boşluklar olmamalı)
2. 2 Adımlı Doğrulama'nın aktif olduğundan emin olun
3. Gmail hesabının `suheyla0403@gmail.com` olduğundan emin olun

### E-posta gönderilmiyor:

1. Firebase Functions loglarını kontrol edin:
   ```bash
   firebase functions:log
   ```
2. Hata mesajlarını inceleyin
3. Gmail hesabının spam klasörünü kontrol edin

## Güvenlik Notları

⚠️ **ÖNEMLİ:**
- App Password'ü asla kod içine yazmayın
- App Password'ü Git'e commit etmeyin
- `.env` dosyasını `.gitignore`'a ekleyin
- Production'da mutlaka Firebase Functions config kullanın

## İletişim

Sorun yaşarsanız, Firebase Console > Functions > Logs bölümünden hata loglarını kontrol edin.

