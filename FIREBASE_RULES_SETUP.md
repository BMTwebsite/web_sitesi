# Firestore Security Rules Kurulumu

Firestore'a yazma işlemi timeout oluyorsa, muhtemelen Security Rules yazma izni vermiyor. İşte çözüm:

## Hızlı Çözüm (Test Mode - Geliştirme İçin)

Eğer Firestore'u **Test Mode**'da başlattıysanız, 30 gün boyunca herkes yazabilir. Ancak bu süre dolduysa veya Native Mode kullanıyorsanız, rules ayarlamanız gerekir.

## Adım 1: Firebase Console'da Rules Ayarlama

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin: **bmt-web-41790**
3. Sol menüden **Firestore Database**'e tıklayın
4. **Rules** sekmesine gidin
5. Aşağıdaki kuralları yapıştırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events koleksiyonu - herkes okuyabilir
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Pending Admins - herkes kayıt olabilir
    match /pending_admins/{pendingId} {
      allow read: if request.auth != null;
      allow create: if true; // Herkes kayıt olabilir
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }
    
    // Admins - authenticated kullanıcılar
    match /admins/{adminId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

6. **Publish** butonuna tıklayın

## Adım 2: Firebase CLI ile Deploy (Alternatif)

Eğer Firebase CLI kuruluysa:

1. **firestore.rules dosyasını oluşturun** (zaten oluşturuldu)
2. **firebase.json dosyası oluşturun:**

```json
{
  "firestore": {
    "rules": "firestore.rules"
  }
}
```

3. **Deploy edin:**
```bash
firebase deploy --only firestore:rules
```

## Test Etme

1. Admin kayıt sayfasından bir kullanıcı kaydedin
2. Hata almamalısınız
3. Firebase Console'da `pending_admins` koleksiyonunu kontrol edin
4. Yeni bir doküman görünmeli

## Sorun Giderme

### Hala timeout alıyorsanız:

1. **Firebase Console'da Rules'ı kontrol edin:**
   - Rules sekmesinde yukarıdaki kuralların olduğundan emin olun
   - **Publish** butonuna tıkladığınızdan emin olun

2. **Firestore Mode'unu kontrol edin:**
   - Firestore Database > Overview
   - Native mode'da olmalı (Test mode değil)
   - Eğer Test mode'daysa, 30 gün içinde herkes yazabilir

3. **İnternet bağlantısını kontrol edin:**
   - Tarayıcı konsolunda network hatalarını kontrol edin
   - Firebase servislerinin erişilebilir olduğundan emin olun

4. **Firebase proje ayarlarını kontrol edin:**
   - Firebase Console > Project Settings
   - Firestore'un aktif olduğundan emin olun

## Production İçin Güvenlik

Production'da daha sıkı kurallar kullanın:

```javascript
match /pending_admins/{pendingId} {
  allow read: if request.auth != null && 
    request.auth.token.email.matches('.*@bmt\\.edu\\.tr$');
  allow create: if request.resource.data.email is string &&
    request.resource.data.email.matches('.*@.*');
  allow update, delete: if false; // Sadece sistem güncelleyebilir
}
```

Şimdilik yukarıdaki kurallar geliştirme için yeterli.

