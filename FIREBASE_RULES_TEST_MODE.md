# 🔧 Firestore Rules Hatası - Test Mode Çözümü

Eğer Firestore Security Rules hatası devam ediyorsa, en hızlı çözüm **Test Mode**'a geçmektir.

## Adım 1: Firebase Console'a Gidin
👉 https://console.firebase.google.com/project/bmt-web-41790/firestore/database

## Adım 2: Test Mode'u Aktifleştirin
1. Firestore Database sayfasında
2. Eğer "Native mode" görüyorsanız, **"Test mode"** seçeneğini bulun
3. Test mode'u seçin ve onaylayın

## Test Mode Ne Yapar?
- ✅ 30 gün boyunca **herkes** Firestore'a yazabilir
- ✅ Rules ayarlamaya gerek yok
- ✅ Hemen çalışır

## ⚠️ Önemli Notlar
- Test mode **30 gün** geçerlidir
- 30 gün sonra rules ayarlamanız gerekir
- Production için rules ayarlamalısınız

## Alternatif: Rules'ı Manuel Ayarlama

Eğer test mode kullanmak istemiyorsanız:

1. Firebase Console > Firestore Database > Rules
2. Tüm mevcut kuralları silin
3. Şu kuralları yapıştırın:

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

4. **Publish** butonuna tıklayın
5. 10-30 saniye bekleyin
6. Uygulamayı yeniden başlatın

---

## Hala Çalışmıyorsa

1. Tarayıcı konsolunu açın (F12)
2. Console sekmesine gidin
3. Kırmızı hata mesajlarını kontrol edin
4. Hata mesajını paylaşın

