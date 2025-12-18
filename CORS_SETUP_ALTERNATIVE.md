# CORS Ayarları - Alternatif Yöntemler

Proje ID: **bmt-web-41790**

## Yöntem 1: Firebase Console'dan Google Cloud Console'a Geçiş

1. **Firebase Console'u açın:**
   - https://console.firebase.google.com/
   - Projenizi seçin (bmt-web-41790)

2. **Project Settings'e gidin:**
   - Sol alttaki ⚙️ (Settings) ikonuna tıklayın
   - **Project settings** seçin

3. **Google Cloud Console'a geçin:**
   - **Project settings** sayfasında **Google Cloud Platform** bölümünü bulun
   - **Open in Google Cloud Console** veya benzer bir butona tıklayın
   - Veya doğrudan şu linke gidin: https://console.cloud.google.com/storage/browser?project=bmt-web-41790

4. **Cloud Shell'i açın:**
   - Google Cloud Console'da sağ üstteki ☁️ (Cloud Shell) ikonuna tıklayın

5. **Komutları çalıştırın:**
   ```bash
   echo '[{"origin": ["*"], "method": ["GET", "HEAD"], "maxAgeSeconds": 3600}]' > cors.json
   gsutil cors set cors.json gs://bmt-web-41790.appspot.com
   gsutil cors get gs://bmt-web-41790.appspot.com
   ```

---

## Yöntem 2: Doğrudan Link ile Google Cloud Console

1. **Doğrudan bu linke gidin:**
   ```
   https://console.cloud.google.com/storage/browser?project=bmt-web-41790
   ```

2. **Giriş yapın:**
   - Google hesabınızla giriş yapın (Firebase ile aynı hesap)

3. **Cloud Shell'i açın:**
   - Sağ üstteki ☁️ ikonuna tıklayın

4. **Komutları çalıştırın:**
   ```bash
   echo '[{"origin": ["*"], "method": ["GET", "HEAD"], "maxAgeSeconds": 3600}]' > cors.json
   gsutil cors set cors.json gs://bmt-web-41790.appspot.com
   ```

---

## Yöntem 3: Proje Seçimi Manuel

1. **Google Cloud Console'u açın:**
   - https://console.cloud.google.com/

2. **Proje seçimi:**
   - Üst kısımda proje seçiciye tıklayın
   - **"bmt-web-41790"** veya **"BMT Web"** gibi bir isim arayın
   - Eğer görünmüyorsa:
     - **"NEW PROJECT"** butonuna tıklayın
     - Ama önce Firebase Console'da proje ID'nizi doğrulayın

3. **Firebase Console'da proje ID kontrolü:**
   - Firebase Console → Project Settings → General
   - **Project ID** kısmını kontrol edin
   - Eğer farklıysa, o ID'yi kullanın

---

## Yöntem 4: Firebase CLI ile (Eğer Cloud Shell çalışmazsa)

Firebase CLI zaten yüklü, ama CORS için `gsutil` gerekiyor. Alternatif:

1. **Firebase Console → Storage → Files**
   - Görsellerinizin yüklü olduğundan emin olun

2. **Browser Console'da test edin:**
   - F12 → Console
   - Şu komutu çalıştırın:
   ```javascript
   fetch('https://firebasestorage.googleapis.com/v0/b/bmt-web-41790.appspot.com/o/events%2Ftest.jpg')
     .then(r => console.log('CORS OK:', r))
     .catch(e => console.log('CORS Error:', e))
   ```

---

## Sorun Giderme

### Proje görünmüyorsa:

1. **Firebase Console'da proje ID'yi doğrulayın:**
   - Firebase Console → Project Settings → General
   - **Project ID** değerini not edin

2. **Google Cloud Console'da proje listesini kontrol edin:**
   - Tüm projeleri göster
   - Firebase projeleri genellikle aynı isimle görünür

3. **Farklı Google hesabı kullanıyor olabilirsiniz:**
   - Firebase Console'da hangi hesap ile giriş yaptığınızı kontrol edin
   - Google Cloud Console'da aynı hesap ile giriş yapın

---

## En Hızlı Çözüm

Eğer hiçbiri çalışmazsa, Firebase Console'dan doğrudan link:

1. Firebase Console → Project Settings → General
2. **Project ID** değerini kopyalayın
3. Şu linki açın (PROJECT-ID yerine yapıştırın):
   ```
   https://console.cloud.google.com/storage/browser?project=PROJECT-ID
   ```
4. Cloud Shell'i açın ve komutları çalıştırın

