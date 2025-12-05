# Firestore Timeout Hatası - Adım Adım Çözüm

## ⚠️ Hata: "Kayıt işlemi zaman aşımına uğradı"

Bu hata, Firestore Security Rules'ın yazma izni vermemesinden kaynaklanıyor.

## 🔧 Çözüm 1: Firestore Security Rules Ayarlama (Önerilen)

### Adım 1: Firebase Console'a Gidin
1. [Firebase Console](https://console.firebase.google.com/) açın
2. Projenizi seçin: **bmt-web-41790**

### Adım 2: Firestore Database'e Gidin
1. Sol menüden **Firestore Database** tıklayın
2. Üst menüden **Rules** sekmesine tıklayın

### Adım 3: Mevcut Kuralları Kontrol Edin
Şu anda ne yazıyor? Eğer şöyle bir şey görüyorsanız:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false; // ❌ Bu her şeyi engelliyor!
    }
  }
}
```

Bu yanlış! Değiştirmeniz gerekiyor.

### Adım 4: Doğru Kuralları Yapıştırın
Tüm mevcut kuralları silin ve şunları yapıştırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events - herkes okuyabilir
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Pending Admins - HERKES kayıt olabilir
    match /pending_admins/{pendingId} {
      allow read: if request.auth != null;
      allow create: if true; // ✅ ÖNEMLİ: Herkes kayıt olabilir
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }
    
    // Admins
    match /admins/{adminId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Adım 5: Publish Butonuna Tıklayın
1. **Publish** butonuna tıklayın (sağ üstte)
2. Onaylayın
3. Birkaç saniye bekleyin (rules yayınlanıyor)

### Adım 6: Uygulamayı Test Edin
1. Uygulamayı yeniden başlatın (hot restart: `R` tuşu)
2. Kayıt sayfasından tekrar deneyin

## 🔧 Çözüm 2: Test Mode'a Geçme (Geçici Çözüm)

Eğer rules ayarlamak istemiyorsanız:

1. Firebase Console > Firestore Database
2. **Overview** sekmesine gidin
3. Eğer "Native mode" görüyorsanız, **Test mode**'a geçin
4. Test mode'da 30 gün boyunca herkes yazabilir

**Not:** Test mode production için güvenli değildir, sadece geliştirme için kullanın.

## 🔧 Çözüm 3: Firestore'u Yeniden Başlatma

Bazen Firestore bağlantısı kopuyor:

1. Firebase Console > Firestore Database
2. **Settings** (⚙️) > **General**
3. Firestore'u kontrol edin, aktif olduğundan emin olun

## ✅ Kontrol Listesi

- [ ] Firebase Console'da Rules sekmesine gittim
- [ ] Mevcut kuralları sildim
- [ ] Yukarıdaki kuralları yapıştırdım
- [ ] **Publish** butonuna tıkladım
- [ ] Uygulamayı yeniden başlattım (hot restart)
- [ ] Tekrar denedim

## 🐛 Hala Çalışmıyorsa

1. **Tarayıcı konsolunu açın** (F12)
2. **Console** sekmesine gidin
3. Kayıt işlemini tekrar deneyin
4. Kırmızı hata mesajlarını kontrol edin
5. Hata mesajını bana gönderin

## 📸 Ekran Görüntüsü İçin

Firebase Console'da Rules sekmesinde şöyle görünmeli:

```
Rules sekmesi açık
Publish butonu görünüyor
Yukarıdaki kurallar yazılı
```

Eğer farklı bir şey görüyorsanız, ekran görüntüsü paylaşın.

