# Firebase Storage CORS Ayarları

Web uygulamanızda görsellerin gözükmemesi genellikle **CORS (Cross-Origin Resource Sharing)** ayarları ile ilgilidir. Firebase Storage'da CORS ayarlarını yapılandırmanız gerekir.

## Sorun

Web uygulamanızda Firebase Storage'dan görseller yüklenirken şu hatalar görülebilir:
- Görseller gözükmüyor
- Console'da CORS hatası
- "Access-Control-Allow-Origin" hatası

## Çözüm: Firebase Storage CORS Ayarları

### 1. CORS Yapılandırma Dosyası Oluşturun

Proje kök dizininizde `cors.json` adında bir dosya oluşturun:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600
  }
]
```

**Not:** Production ortamında `"origin": ["*"]` yerine kendi domain'inizi kullanın:
```json
[
  {
    "origin": ["https://yourdomain.com", "https://www.yourdomain.com"],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600
  }
]
```

### 2. CORS Ayarlarını Firebase Storage'a Uygulayın

Terminal'de şu komutu çalıştırın:

```bash
gsutil cors set cors.json gs://YOUR-PROJECT-ID.appspot.com
```

**Yerine koymanız gerekenler:**
- `YOUR-PROJECT-ID`: Firebase Console'dan proje ID'nizi alın
- `cors.json`: Oluşturduğunuz dosyanın yolu

### 3. Alternatif: Firebase Console Üzerinden

1. [Firebase Console](https://console.firebase.google.com/) → Projenizi seçin
2. **Storage** sekmesine gidin
3. **Settings** (Ayarlar) → **CORS configuration** bölümüne gidin
4. CORS ayarlarını yapılandırın

### 4. Doğrulama

CORS ayarlarını kontrol etmek için:

```bash
gsutil cors get gs://YOUR-PROJECT-ID.appspot.com
```

## Storage Rules Kontrolü

Ayrıca `storage.rules` dosyanızın doğru yapılandırıldığından emin olun:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Events klasörü - herkes okuyabilir
    match /events/{eventId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null; // Sadece giriş yapmış kullanıcılar yazabilir
    }
    
    // Diğer klasörler...
  }
}
```

## Hata Ayıklama

### Browser Console'da Kontrol Edin

1. Browser'ınızda Developer Tools'u açın (F12)
2. **Console** sekmesine gidin
3. Görsel yükleme sırasında hataları kontrol edin:
   - CORS hatası görüyorsanız → CORS ayarlarını yapın
   - 403 Forbidden hatası → Storage Rules'ı kontrol edin
   - 404 Not Found → Görsel URL'sinin doğru olduğundan emin olun

### Network Tab'inde Kontrol Edin

1. Developer Tools → **Network** sekmesi
2. Görsel yükleme isteğini bulun
3. **Headers** sekmesinde:
   - `Access-Control-Allow-Origin` header'ının olup olmadığını kontrol edin
   - Response status code'u kontrol edin (200 OK olmalı)

## Önemli Notlar

1. **CORS ayarları değişiklikleri hemen etkili olmayabilir** - birkaç dakika bekleyin
2. **Production'da güvenlik için** `origin: ["*"]` yerine spesifik domain'ler kullanın
3. **Storage Rules** ve **CORS** ayarları birlikte çalışır - ikisini de doğru yapılandırın

## Hızlı Test

CORS ayarlarının çalışıp çalışmadığını test etmek için:

```bash
curl -H "Origin: https://yourdomain.com" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     -X OPTIONS \
     https://firebasestorage.googleapis.com/v0/b/YOUR-PROJECT-ID.appspot.com/o/events%2Ftest.jpg
```

Başarılı bir yanıt `Access-Control-Allow-Origin` header'ı içermelidir.

