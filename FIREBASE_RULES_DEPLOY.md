# 🔧 Firebase Rules Deploy Rehberi

## Yöntem 1: Firebase CLI ile Deploy (Önerilen)

### Adım 1: Firebase'e Giriş Yapın
```bash
firebase login
```

### Adım 2: Projeyi Bağlayın
```bash
firebase use bmt-web-41790
```

### Adım 3: Rules'ı Deploy Edin
```bash
firebase deploy --only firestore:rules
```

---

## Yöntem 2: Firebase Console'dan Manuel

### Adım 1: Firebase Console'a Gidin
👉 https://console.firebase.google.com/project/bmt-web-41790/firestore/rules

### Adım 2: Mevcut Kuralları Silin
- Ctrl+A (tümünü seç)
- Delete (sil)

### Adım 3: Yeni Kuralları Yapıştırın
`firestore.rules` dosyasındaki kuralları kopyalayıp yapıştırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pending_admins/{document=**} {
      allow read, write: if true;
    }
    match /events/{document=**} {
      allow read, write: if true;
    }
    match /admins/{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Adım 4: Publish Butonuna Tıklayın
- Sağ üstteki **"Publish"** butonuna tıklayın
- Onaylayın

### Adım 5: Bekleyin
- 10-30 saniye bekleyin
- Rules sekmesinde "Published" yazısını kontrol edin

### Adım 6: Uygulamayı Yeniden Başlatın
- Flutter uygulamasında **R** tuşuna basın (hot restart)

---

## Sorun Giderme

### Rules Görünmüyor?
1. Tarayıcıyı yenileyin (Ctrl+F5)
2. Farklı bir tarayıcı deneyin
3. Rules sekmesinde "Published" yazısını kontrol edin

### Hala Çalışmıyor?
1. Tarayıcı konsolunu açın (F12)
2. Console sekmesine gidin
3. Kırmızı hata mesajlarını kontrol edin
4. Rules'ın yayınlandığından emin olun (30 saniye bekleyin)

