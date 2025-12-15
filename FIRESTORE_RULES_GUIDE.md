# Firestore Security Rules Kurulum Rehberi

## 🔴 ÖNEMLİ: Firebase Console'da Rules'ı Publish Etmeyi Unutmayın!

Firestore rules dosyasını güncelledikten sonra **MUTLAKA** Firebase Console'da publish etmeniz gerekiyor!

## Adım Adım Kurulum

### 1. Firebase Console'a Gidin
1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin

### 2. Firestore Database > Rules Sekmesine Gidin
1. Sol menüden **Firestore Database**'e tıklayın
2. Üst menüden **Rules** sekmesine geçin

### 3. Rules'ı Kopyalayın
Aşağıdaki rules'ı tamamen kopyalayıp Firebase Console'daki Rules editörüne yapıştırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Geçici olarak tüm koleksiyonlara tam erişim (test için)
    // Production'da daha güvenli kurallar kullanılmalı
    
    // Pending Admins
    match /pending_admins/{document=**} {
      allow read, write: if true;
    }
    
    // Events
    match /events/{document=**} {
      allow read, write: if true;
    }
    
    // Admins
    match /admins/{document=**} {
      allow read, write: if true;
    }
    
    // Mail koleksiyonu - Trigger Email extension için gerekli
    match /mail/{document=**} {
      allow read, write: if true;
    }
    
    // Site settings - herkes okuyabilir, herkes yazabilir (test için)
    match /site_settings/{document=**} {
      allow read, write: if true;
    }
    
    // Contact settings - herkes okuyabilir, herkes yazabilir (test için)
    match /contact_settings/{document=**} {
      allow read, write: if true;
    }
    
    // Announcements - herkes okuyabilir, herkes yazabilir (test için)
    match /announcements/{document=**} {
      allow read, write: if true;
    }
    
    // Teams - herkes okuyabilir, herkes yazabilir (test için)
    match /teams/{document=**} {
      allow read, write: if true;
    }
    
    // Team Members - herkes okuyabilir, herkes yazabilir (test için)
    match /team_members/{document=**} {
      allow read, write: if true;
    }
    
    // Sponsors - herkes okuyabilir, herkes yazabilir (test için)
    match /sponsors/{document=**} {
      allow read, write: if true;
    }
  }
}
```

### 4. Rules'ı Publish Edin
1. Rules editörünün sağ üst köşesinde **Publish** butonuna tıklayın
2. Onay mesajını bekleyin
3. "Rules published successfully" mesajını görmelisiniz

### 5. Doğrulama
Rules publish edildikten sonra:
- Sayfayı yenileyin (F5)
- Sponsorlar, Ekipler ve Duyurular sayfalarını kontrol edin
- Artık veriler görünmeli

## Sorun Giderme

### "Permission denied" hatası devam ediyorsa:

1. **Rules'ı tekrar kontrol edin**
   - Firebase Console > Firestore Database > Rules
   - Rules'ın doğru şekilde yapıştırıldığından emin olun
   - Syntax hatası olup olmadığını kontrol edin

2. **Publish butonuna tıkladığınızdan emin olun**
   - Rules'ı sadece yazmak yeterli değil, mutlaka publish etmelisiniz
   - Publish edilmeden rules aktif olmaz

3. **Sayfayı yenileyin**
   - Rules publish edildikten sonra tarayıcıyı yenileyin (F5)
   - Bazen cache sorunu olabilir

4. **Koleksiyonların var olduğundan emin olun**
   - Firebase Console > Firestore Database > Data sekmesine gidin
   - `sponsors`, `teams`, `team_members`, `announcements` koleksiyonlarının var olduğunu kontrol edin
   - Eğer yoksa, admin panelinden bir veri ekleyerek oluşturun

5. **Tarayıcı konsolunu kontrol edin**
   - F12 tuşuna basarak Developer Tools'u açın
   - Console sekmesinde hata mesajlarını kontrol edin
   - Detaylı hata bilgisi görebilirsiniz

## Production İçin Güvenlik Notu

⚠️ **ÖNEMLİ:** Şu anda tüm koleksiyonlar için `allow read, write: if true;` kullanıyoruz. Bu, herkesin okuyup yazabileceği anlamına gelir.

Production ortamında daha güvenli kurallar kullanmalısınız:

```javascript
// Örnek: Sadece authenticated kullanıcılar yazabilir
match /teams/{document=**} {
  allow read: if true;  // Herkes okuyabilir
  allow write: if request.auth != null;  // Sadece giriş yapmış kullanıcılar yazabilir
}
```

## Destek

Sorun devam ederse:
1. Firebase Console'da Rules sekmesinde syntax hatası var mı kontrol edin
2. Tarayıcı konsolundaki hata mesajlarını paylaşın
3. Firebase Console'da Rules'ın publish edildiğinden emin olun

