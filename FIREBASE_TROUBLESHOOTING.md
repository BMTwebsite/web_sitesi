# Firebase Okuma Hatası Çözüm Rehberi

## 🔴 EN ÖNEMLİ ADIM: Firebase Console'da Rules'ı Publish Edin!

Firebase'den okuma hatası alıyorsanız, **MUTLAKA** Firebase Console'da Firestore Security Rules'ı publish etmeniz gerekiyor!

## Adım Adım Çözüm

### 1. Firebase Console'a Gidin
1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin: **bmt-web-41790**

### 2. Firestore Database > Rules Sekmesine Gidin
1. Sol menüden **Firestore Database**'e tıklayın
2. Üst menüden **Rules** sekmesine geçin

### 3. Rules'ı Kontrol Edin
Aşağıdaki rules'ın tamamen yapıştırıldığından emin olun:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Geçici olarak tüm koleksiyonlara tam erişim (test için)
    
    match /pending_admins/{document=**} {
      allow read, write: if true;
    }
    
    match /events/{document=**} {
      allow read, write: if true;
    }
    
    match /admins/{document=**} {
      allow read, write: if true;
    }
    
    match /mail/{document=**} {
      allow read, write: if true;
    }
    
    match /site_settings/{document=**} {
      allow read, write: if true;
    }
    
    match /contact_settings/{document=**} {
      allow read, write: if true;
    }
    
    match /announcements/{document=**} {
      allow read, write: if true;
    }
    
    match /teams/{document=**} {
      allow read, write: if true;
    }
    
    match /team_members/{document=**} {
      allow read, write: if true;
    }
    
    match /sponsors/{document=**} {
      allow read, write: if true;
    }
  }
}
```

### 4. 🔴 PUBLISH BUTONUNA TIKLAYIN!
**BU ADIM ÇOK ÖNEMLİ!** Rules'ı sadece yazmak yeterli değil, mutlaka publish etmelisiniz:

1. Rules editörünün **sağ üst köşesinde** **"Publish"** butonunu bulun
2. **Publish** butonuna tıklayın
3. Onay mesajını bekleyin
4. **"Rules published successfully"** mesajını görmelisiniz

### 5. Sayfayı Yenileyin
1. Tarayıcıda **F5** tuşuna basın veya sayfayı yenileyin
2. Sponsorlar, Ekipler ve Duyurular sayfalarını tekrar kontrol edin

## Sorun Devam Ediyorsa

### Kontrol Listesi:

✅ **Firebase Console'da Rules sekmesine gittiniz mi?**
✅ **Rules'ı yukarıdaki gibi yapıştırdınız mı?**
✅ **Publish butonuna tıkladınız mı?** ← EN ÖNEMLİSİ!
✅ **"Rules published successfully" mesajını gördünüz mü?**
✅ **Sayfayı yenilediniz mi? (F5)**

### Hala Çalışmıyorsa:

1. **Tarayıcı Konsolunu Kontrol Edin**
   - F12 tuşuna basın
   - Console sekmesine gidin
   - Hata mesajlarını kontrol edin
   - Kırmızı hata mesajlarını paylaşın

2. **Firebase Console'da Rules'ı Tekrar Kontrol Edin**
   - Rules sekmesinde syntax hatası var mı?
   - Tüm koleksiyonlar eklenmiş mi?
   - Rules'ın publish edildiğinden emin olun

3. **Koleksiyonların Var Olduğunu Kontrol Edin**
   - Firebase Console > Firestore Database > **Data** sekmesine gidin
   - `sponsors`, `teams`, `team_members`, `announcements` koleksiyonlarının var olduğunu kontrol edin
   - Eğer yoksa, admin panelinden bir veri ekleyerek oluşturun

4. **İnternet Bağlantınızı Kontrol Edin**
   - Firebase servislerine erişebildiğinizden emin olun
   - VPN kullanıyorsanız kapatıp deneyin

## Hata Mesajları ve Çözümleri

### "Permission denied" hatası
**Çözüm:** Firebase Console'da Rules'ı publish edin!

### "Missing or insufficient permissions" hatası
**Çözüm:** Rules'da ilgili koleksiyon için `allow read: if true;` olduğundan emin olun ve publish edin!

### "Failed to get document" hatası
**Çözüm:** Koleksiyonun var olduğundan emin olun. Admin panelinden bir veri ekleyerek oluşturun.

### "Network error" hatası
**Çözüm:** İnternet bağlantınızı kontrol edin. Firebase servislerine erişebildiğinizden emin olun.

## Hızlı Test

Rules'ı publish ettikten sonra şu adımları izleyin:

1. Tarayıcıyı tamamen kapatıp yeniden açın
2. Uygulamayı yeniden yükleyin
3. Sponsorlar sayfasına gidin
4. Eğer hala hata varsa, tarayıcı konsolundaki (F12) hata mesajını paylaşın

## Destek

Sorun devam ederse:
1. Tarayıcı konsolundaki (F12) tam hata mesajını paylaşın
2. Firebase Console'da Rules sekmesinin ekran görüntüsünü paylaşın
3. Rules'ın publish edildiğinden emin olun

