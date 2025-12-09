# Resend E-posta Kurulumu (Şifre Gerektirmez!)

Resend, modern bir e-posta servisidir. **Şifre gerektirmez**, sadece API key yeterlidir.

## Avantajlar

✅ **Şifre gerektirmez** - Sadece API key yeterli  
✅ **Ücretsiz plan**: 100 email/gün, 3000 email/ay  
✅ **Kolay kurulum** - 5 dakikada hazır  
✅ **Güvenli** - API key ile çalışır  
✅ **Spam'a gitmez** - Profesyonel altyapı  

## Kurulum Adımları

### 1. Resend'e Kayıt Olun

1. https://resend.com adresine gidin
2. **Sign Up** butonuna tıklayın
3. E-posta adresinizle kayıt olun (ücretsiz)
4. E-postanızı doğrulayın

### 2. API Key Oluşturun

1. Resend Dashboard'a giriş yapın: https://resend.com/api-keys
2. **Create API Key** butonuna tıklayın
3. İsim verin: "Firebase Functions"
4. **Permissions**: "Sending access" seçin
5. **Create** butonuna tıklayın
6. **API Key'i kopyalayın** (sadece bir kez gösterilir!)

### 3. Domain Ekleme (İsteğe Bağlı - İlk Kullanımda Gerekli Değil)

**İlk kullanımda** `onboarding@resend.dev` adresini kullanabilirsiniz.  
**Production için** kendi domain'inizi eklemeniz önerilir:

1. Resend Dashboard > **Domains** sekmesine gidin
2. **Add Domain** butonuna tıklayın
3. Domain'inizi girin (örn: `bmt.edu.tr`)
4. DNS kayıtlarını ekleyin (SPF, DKIM, DMARC)
5. Domain doğrulandıktan sonra kullanabilirsiniz

### 4. Firebase Functions'a API Key Ekleme

Oluşturduğunuz API Key'i Firebase Functions'a ekleyin:

```bash
firebase functions:config:set resend.api_key="YOUR_API_KEY"
```

**Örnek:**
```bash
firebase functions:config:set resend.api_key="re_1234567890abcdef"
```

### 5. Paketleri Yükleyin ve Deploy Edin

```bash
cd functions
npm install
firebase deploy --only functions
```

## Kullanım

Artık admin kayıt sayfasından kayıt olduğunuzda, e-posta otomatik olarak `suheyla0403@gmail.com` adresine gönderilecektir.

## Domain Ayarlama (Production İçin)

Kendi domain'inizi kullanmak isterseniz:

1. Resend Dashboard > Domains > Add Domain
2. Domain'inizi ekleyin (örn: `bmt.edu.tr`)
3. DNS kayıtlarını ekleyin:
   - **SPF**: `v=spf1 include:_spf.resend.com ~all`
   - **DKIM**: Resend tarafından verilen kayıtları ekleyin
   - **DMARC**: `v=DMARC1; p=none; rua=mailto:admin@bmt.edu.tr`

4. Domain doğrulandıktan sonra `functions/index.js` dosyasında:
   ```javascript
   from: 'BMT Web Sitesi <noreply@bmt.edu.tr>',
   ```

## Sorun Giderme

### "Resend API Key ayarlanmamış" hatası

1. API Key'in doğru kopyalandığından emin olun
2. Firebase Functions config'i kontrol edin:
   ```bash
   firebase functions:config:get
   ```
3. Deploy işlemini tekrar yapın:
   ```bash
   firebase deploy --only functions
   ```

### E-posta gönderilmiyor

1. Firebase Functions loglarını kontrol edin:
   ```bash
   firebase functions:log
   ```
2. Resend Dashboard > Logs sekmesinden gönderim durumunu kontrol edin
3. API Key'in "Sending access" iznine sahip olduğundan emin olun

### Spam'a gidiyor

1. Domain'inizi doğrulayın ve DNS kayıtlarını ekleyin
2. "From" adresini kendi domain'inizden kullanın
3. E-posta içeriğinde spam kelimeler kullanmayın

## Limitler (Ücretsiz Plan)

- **100 email/gün**
- **3000 email/ay**
- İlk kullanımda `onboarding@resend.dev` kullanılabilir
- Production için domain doğrulaması önerilir

## Güvenlik

⚠️ **ÖNEMLİ:**
- API Key'i asla kod içine yazmayın
- API Key'i Git'e commit etmeyin
- Firebase Functions config kullanın
- API Key'i sadece "Sending access" izniyle oluşturun

## İletişim

Sorun yaşarsanız:
- Resend Dashboard > Logs: Gönderim durumunu kontrol edin
- Firebase Functions Logs: `firebase functions:log`
- Resend Support: https://resend.com/support

