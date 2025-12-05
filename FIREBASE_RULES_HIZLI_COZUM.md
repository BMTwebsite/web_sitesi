# ⚡ Hızlı Çözüm - Firestore Rules

## Adım 1: Firebase Console'a Gidin
👉 https://console.firebase.google.com/project/bmt-web-41790/firestore/rules

## Adım 2: Mevcut Kuralları Silin
Rules editöründeki TÜM metni seçin ve silin (Ctrl+A, Delete)

## Adım 3: Şu Kuralları Yapıştırın

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pending_admins/{pendingId} {
      allow create: if true;
      allow read, update, delete: if request.auth != null;
    }
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /admins/{adminId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Adım 4: Publish Butonuna Tıklayın
Sağ üstteki **"Publish"** butonuna tıklayın ve onaylayın.

## Adım 5: Bekleyin
Rules yayınlanması 10-30 saniye sürebilir.

## Adım 6: Uygulamayı Yeniden Başlatın
Flutter uygulamasında **R** tuşuna basın (hot restart) veya uygulamayı kapatıp açın.

## Adım 7: Tekrar Deneyin
Kayıt sayfasından tekrar kayıt olmayı deneyin.

---

## ❌ Hala Çalışmıyorsa

### Seçenek 1: Test Mode'a Geçin
1. Firebase Console > Firestore Database > Overview
2. Eğer "Native mode" görüyorsanız
3. **Test mode**'a geçin (30 gün boyunca herkes yazabilir)

### Seçenek 2: Tarayıcı Konsolunu Kontrol Edin
1. F12 tuşuna basın
2. Console sekmesine gidin
3. Kırmızı hata mesajlarını kontrol edin
4. Hata mesajını bana gönderin

### Seçenek 3: Firestore'un Aktif Olduğundan Emin Olun
1. Firebase Console > Firestore Database
2. Overview sekmesinde Firestore'un aktif olduğunu kontrol edin
3. Eğer "Create database" görüyorsanız, tıklayın ve Native mode seçin

---

## 📸 Ekran Görüntüsü Kontrolü

Rules sekmesinde şöyle görünmeli:
- ✅ Sol tarafta rules editörü
- ✅ Sağ üstte "Publish" butonu
- ✅ Yukarıdaki kurallar yazılı
- ✅ "Publish" butonuna tıkladıktan sonra "Published" yazısı görünmeli

Eğer farklı bir şey görüyorsanız, ekran görüntüsü paylaşın.

