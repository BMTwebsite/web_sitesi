# Firebase Storage CORS Ayarları - Hızlı Kurulum

Proje ID: **bmt-web-41790**

## Yöntem 1: Google Cloud Shell (Önerilen - En Kolay) ⭐

1. **Google Cloud Console'u açın:**
   - https://console.cloud.google.com/ adresine gidin
   - Firebase projenizi seçin (bmt-web-41790)

2. **Cloud Shell'i başlatın:**
   - Sağ üst köşedeki **terminal simgesine** (☁️) tıklayın
   - Cloud Shell otomatik olarak açılacak

3. **CORS dosyasını oluşturun:**
   ```bash
   echo '[{"origin": ["*"], "method": ["GET", "HEAD"], "maxAgeSeconds": 3600}]' > cors.json
   ```

4. **CORS ayarlarını uygulayın:**
   ```bash
   gsutil cors set cors.json gs://bmt-web-41790.appspot.com
   ```

5. **Doğrulayın:**
   ```bash
   gsutil cors get gs://bmt-web-41790.appspot.com
   ```

✅ **Tamamlandı!** Artık görselleriniz web uygulamanızda görünecek.

---

## Yöntem 2: Google Cloud Console (Manuel - Alternatif)

**Not:** Firebase Console'da CORS ayarları yoktur. Google Cloud Console kullanmanız gerekir.

1. **Google Cloud Console'u açın:**
   - https://console.cloud.google.com/ adresine gidin
   - Üst kısımdan projenizi seçin (bmt-web-41790)

2. **Cloud Storage'a gidin:**
   - Sol menüden **Cloud Storage** → **Buckets** seçin
   - `bmt-web-41790.appspot.com` bucket'ını bulun

3. **CORS ayarları:**
   - Bucket'a tıklayın
   - **Configuration** (Yapılandırma) sekmesine gidin
   - **CORS** bölümünü bulun ve düzenleyin
   - Veya **Cloud Shell** kullanarak komutla yapın (Yöntem 1 daha kolay)

---

## Yöntem 3: Google Cloud SDK Yükleme (Yerel)

Eğer yerel olarak yapmak isterseniz:

1. **Google Cloud SDK'yı indirin:**
   - https://cloud.google.com/sdk/docs/install adresinden Windows installer'ı indirin

2. **Kurulum sonrası:**
   ```bash
   gcloud auth login
   gcloud config set project bmt-web-41790
   gsutil cors set cors.json gs://bmt-web-41790.appspot.com
   ```

---

## Önemli Notlar

- ⚠️ CORS ayarları değişiklikleri **birkaç dakika** içinde etkili olur
- 🔒 Production ortamında `"origin": ["*"]` yerine kendi domain'inizi kullanın:
  ```json
  "origin": ["https://yourdomain.com", "https://www.yourdomain.com"]
  ```
- 🔄 Değişikliklerden sonra tarayıcı cache'ini temizleyin (Ctrl+Shift+Delete)

---

## Sorun Giderme

### Görseller hala gözükmüyorsa:

1. **Browser Console'u kontrol edin (F12):**
   - CORS hatası var mı?
   - Network tab'inde görsel istekleri başarılı mı?

2. **CORS ayarlarını kontrol edin:**
   ```bash
   gsutil cors get gs://bmt-web-41790.appspot.com
   ```

3. **Storage Rules'ı kontrol edin:**
   - Firebase Console → Storage → Rules
   - `allow read: if true;` olmalı

4. **Görsel URL'lerini kontrol edin:**
   - URL'ler geçerli mi?
   - Firebase Storage'da dosyalar var mı?

