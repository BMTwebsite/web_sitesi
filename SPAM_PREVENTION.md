# Email Spam'a Gitmemesi İçin Ayarlar

Email'lerin spam klasörüne gitmemesi için aşağıdaki ayarları yapın:

## 1. Gmail App Password Oluşturma

1. **Google Hesabınıza gidin:** https://myaccount.google.com/
2. **Güvenlik** sekmesine gidin
3. **2 Adımlı Doğrulama**'yı etkinleştirin (gerekirse)
4. **Uygulama şifreleri** bölümüne gidin
5. **Uygulama seçin:** "Mail"
6. **Cihaz seçin:** "Diğer (Özel ad)" → "BMT Web Sitesi" yazın
7. **Oluştur** butonuna tıklayın
8. **16 haneli şifreyi kopyalayın** (boşluksuz)

## 2. Firebase Functions Environment Variable Ayarlama

Gmail App Password'u güvenli bir şekilde saklamak için:

```bash
# Firebase Functions klasörüne gidin
cd functions

# Environment variable olarak ayarlayın
firebase functions:config:set gmail.app_password="YOUR_16_DIGIT_PASSWORD"
```

Sonra `functions/index.js` dosyasında:
```javascript
pass: functions.config().gmail.app_password,
```

## 3. functions/index.js Dosyasını Güncelleme

`functions/index.js` dosyasında şu satırları bulun ve güncelleyin:

```javascript
auth: {
  user: 'bmtbanu@gmail.com', // ✅ Zaten güncellendi
  pass: process.env.GMAIL_APP_PASSWORD || functions.config().gmail.app_password || 'YOUR_APP_PASSWORD',
},
```

## 4. Email İçeriği Optimizasyonu (Zaten Yapıldı)

✅ Doğru "From" adresi: `"BMT Web Sitesi" <bmtbanu@gmail.com>`
✅ Reply-To adresi eklendi
✅ Profesyonel email başlığı
✅ HTML ve text versiyonları
✅ Spam'a gitmemesi için headers eklendi

## 5. SPF, DKIM, DMARC Kayıtları (Opsiyonel - Gmail için gerekli değil)

Gmail kullanıyorsanız, Google zaten SPF/DKIM ayarlarını yapıyor. Ancak daha iyi deliverability için:

### SPF Kaydı (Domain için)
```
v=spf1 include:_spf.google.com ~all
```

### DKIM
Gmail otomatik olarak DKIM imzası ekler.

### DMARC (Opsiyonel)
```
v=DMARC1; p=none; rua=mailto:bmtbanu@gmail.com
```

## 6. Deploy Etme

```bash
cd functions
npm install
firebase deploy --only functions
```

## 7. Test Etme

1. Admin kayıt sayfasından bir kullanıcı kaydedin
2. `bmtbanu@gmail.com` adresine email gelmeli
3. **Gelen Kutusu**'nu kontrol edin (Spam'a gitmemeli)
4. Email'deki onay linkine tıklayın

## Sorun Giderme

### Email hala spam'a gidiyor

1. **Gmail'de "Spam değil" olarak işaretleyin:**
   - Email'i açın
   - "Spam değil" butonuna tıklayın
   - Gmail öğrenir ve gelecekte spam'a göndermez

2. **Gönderen adresini güvenilir olarak ekleyin:**
   - Gmail > Ayarlar > Filtreler ve Engellenen Adresler
   - Yeni filtre oluştur
   - Gönderen: `bmtbanu@gmail.com`
   - "Spam'a gitmesin" işaretle

3. **Email içeriğini kontrol edin:**
   - Spam kelimeler kullanmayın (ücretsiz, kazan, vb.)
   - Çok fazla link kullanmayın
   - Büyük harflerle yazmayın

### Email hiç gelmiyor

1. **Firebase Functions loglarını kontrol edin:**
   ```bash
   firebase functions:log
   ```

2. **Gmail App Password'un doğru olduğundan emin olun:**
   - 16 haneli, boşluksuz
   - Son oluşturulan şifreyi kullanın

3. **Firebase Functions'ın deploy edildiğinden emin olun:**
   ```bash
   firebase functions:list
   ```

## Önemli Notlar

- ✅ Email başlığı: "BMT Web Sitesi - Admin Hesabı Onay İsteği" (spam kelimeler yok)
- ✅ Gönderen adı: "BMT Web Sitesi" (profesyonel)
- ✅ Reply-To adresi eklendi
- ✅ HTML ve text versiyonları var
- ✅ Link'ler HTTPS
- ✅ Email içeriği temiz ve profesyonel

Bu ayarlarla email'ler spam'a gitmemeli!

