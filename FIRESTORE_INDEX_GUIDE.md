# Firestore Index Oluşturma Rehberi

## 🔴 Sorun: "failed-precondition" Index Hatası

Ekip üyesi eklerken veya listelerken index hatası alıyorsanız, Firestore'da composite index oluşturmanız gerekiyor.

## Hızlı Çözüm: Otomatik Index Oluşturma

### Yöntem 1: Hata Mesajındaki Linki Kullanın (EN KOLAY!)

1. Tarayıcı konsolunu açın (F12)
2. Index hatası aldığınızda konsolda şuna benzer bir link göreceksiniz:
   ```
   https://console.firebase.google.com/v1/r/project/.../firestore/indexes?create_composite=...
   ```
3. Bu linke tıklayın
4. Firebase Console açılacak ve index otomatik oluşturulacak
5. Index oluşturulduktan sonra (birkaç dakika sürebilir) sayfayı yenileyin

### Yöntem 2: Manuel Index Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin
3. Sol menüden **Firestore Database** > **Indexes** sekmesine gidin
4. **Create Index** butonuna tıklayın
5. Aşağıdaki bilgileri girin:

**Collection ID:** `team_members`

**Fields to index:**
- Field: `teamId` → Order: **Ascending**
- Field: `name` → Order: **Ascending**

6. **Create** butonuna tıklayın
7. Index oluşturulmasını bekleyin (birkaç dakika sürebilir)
8. Index durumu "Enabled" olduğunda hazır!

## Gerekli Index'ler

### 1. team_members Koleksiyonu İçin

**Index 1: teamId + name**
- Collection: `team_members`
- Fields:
  - `teamId` (Ascending)
  - `name` (Ascending)

Bu index, ekip üyelerini teamId'ye göre filtreleyip isme göre sıralamak için gereklidir.

## Geçici Çözüm: orderBy'ı Kaldırma

Eğer index oluşturmak istemiyorsanız, geçici olarak `orderBy` kaldırılabilir. Ancak bu durumda ekip üyeleri sırasız görünecektir.

## Index Durumunu Kontrol Etme

1. Firebase Console > Firestore Database > **Indexes** sekmesine gidin
2. Oluşturduğunuz index'leri görebilirsiniz
3. Index durumu:
   - **Building**: Hala oluşturuluyor (bekleyin)
   - **Enabled**: Hazır ve kullanılabilir ✅
   - **Error**: Hata var (yeniden oluşturmayı deneyin)

## Sorun Giderme

### Index oluşturuldu ama hala hata alıyorum
- Index'in "Enabled" durumunda olduğundan emin olun
- Sayfayı yenileyin (F5)
- Birkaç dakika bekleyin (index oluşturma zaman alabilir)

### Index oluşturma butonu görünmüyor
- Firebase Console'da doğru projede olduğunuzdan emin olun
- Firestore Database'in Native mode'da olduğundan emin olun

### Index oluşturma çok uzun sürüyor
- Normal! İlk index oluşturma 2-5 dakika sürebilir
- Büyük koleksiyonlarda daha uzun sürebilir
- Bekleyin ve durumu kontrol edin

## Otomatik Index Oluşturma İçin Kod Güncellemesi

Eğer sürekli index hatası alıyorsanız, kod tarafında `orderBy`'ı kaldırabiliriz. Ancak bu durumda veriler sırasız görünecektir.

