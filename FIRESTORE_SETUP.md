# Firestore Kurulum Rehberi

Bu dosya, Firebase Firestore'un doğru şekilde yapılandırılması için gerekli adımları içerir.

## 1. Firestore Security Rules Ayarlama

Firebase Console'da Firestore Database > Rules sekmesine gidin ve aşağıdaki kuralları ekleyin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events koleksiyonu - herkes okuyabilir, sadece adminler yazabilir
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null; // Geçici olarak authenticated kullanıcılar yazabilir
    }
    
    // Pending Admins - herkes yazabilir (kayıt için), sadece adminler okuyabilir
    match /pending_admins/{pendingId} {
      allow read: if request.auth != null; // Authenticated kullanıcılar okuyabilir
      allow write: if true; // Herkes kayıt olabilir
    }
    
    // Admins - sadece adminler okuyabilir/yazabilir
    match /admins/{adminId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Geçici olarak authenticated kullanıcılar yazabilir
    }
  }
}
```

**ÖNEMLİ:** Production ortamında bu kuralları daha sıkı hale getirmelisiniz!

## 2. Firestore Koleksiyonları

Uygulama şu koleksiyonları kullanır:

### `pending_admins`
Bekleyen admin kayıtları burada saklanır:
- `email` (string): Admin e-posta adresi
- `password` (string): Şifre (production'da hash'lenmeli)
- `token` (string): Onay token'ı
- `createdAt` (timestamp): Oluşturulma tarihi
- `verified` (boolean): Onay durumu

### `admins`
Onaylanmış adminler burada saklanır:
- `email` (string): Admin e-posta adresi
- `createdAt` (timestamp): Oluşturulma tarihi

### `events`
Etkinlikler burada saklanır:
- `type` (string): Etkinlik tipi
- `title` (string): Başlık
- `date` (string): Tarih
- `time` (string): Saat
- `location` (string): Konum
- `participants` (number): Katılımcı sayısı
- `colorHex` (string): Renk hex kodu

## 3. Firebase Console'da Verileri Görüntüleme

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin: `bmt-web-41790`
3. Sol menüden **Firestore Database**'e tıklayın
4. **Data** sekmesinde koleksiyonları görebilirsiniz:
   - `pending_admins`: Bekleyen kayıtlar
   - `admins`: Onaylanmış adminler
   - `events`: Etkinlikler

## 4. Test Etme

1. Admin kayıt sayfasından yeni bir kayıt oluşturun
2. Firebase Console'da `pending_admins` koleksiyonunu kontrol edin
3. Yeni bir doküman görünmeli (email, password, token, createdAt, verified alanlarıyla)
4. Onay linkine tıklayınca `admins` koleksiyonuna taşınmalı

## 5. Sorun Giderme

### "Permission denied" hatası alıyorsanız:
- Firestore Security Rules'ı yukarıdaki gibi ayarlayın
- Rules'ı **Publish** butonuna tıklayarak yayınlayın

### Veriler görünmüyorsa:
- Firestore'un **Native mode**'da olduğundan emin olun (Test mode değil)
- İnternet bağlantınızı kontrol edin
- Tarayıcı konsolunda hata mesajlarını kontrol edin

### Timeout hatası alıyorsanız:
- İnternet bağlantınızı kontrol edin
- Firebase servislerinin çalıştığından emin olun
- Firestore quota limitlerini kontrol edin

