# Bekleyen Admin Kayıtlarını Temizleme

Bu script, admin girişi olmadan `pending_admins` koleksiyonundaki tüm bekleyen admin kayıtlarını siler.

## Yöntem 1: Firebase Console'dan Manuel Silme (En Kolay)

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin: `bmt-web-41790`
3. Sol menüden **Firestore Database** > **Data** sekmesine gidin
4. `pending_admins` koleksiyonunu bulun
5. Koleksiyonun üzerine tıklayın
6. Tüm dokümanları seçin (Ctrl+A veya Cmd+A)
7. **Delete** butonuna tıklayın
8. Onaylayın

## Yöntem 2: Node.js Script ile Otomatik Silme

### Gereksinimler

1. Node.js yüklü olmalı
2. Firebase Admin SDK yüklü olmalı

### Kurulum

```bash
# Scripts klasörüne gidin
cd scripts

# Gerekli paketleri yükleyin
npm install firebase-admin
```

### Kullanım

#### Seçenek A: Environment Variable ile (Önerilen)

1. Firebase CLI ile giriş yapın:
   ```bash
   firebase login
   ```

2. Application Default Credentials ayarlayın:
   ```bash
   # Windows PowerShell
   $env:GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
   
   # Windows CMD
   set GOOGLE_APPLICATION_CREDENTIALS=path/to/serviceAccountKey.json
   
   # Linux/Mac
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
   ```

3. Script'i çalıştırın:
   ```bash
   node clear-pending-admins.js
   ```

#### Seçenek B: Service Account Key ile

1. Firebase Console > Project Settings > Service Accounts
2. "Generate new private key" butonuna tıklayın
3. İndirilen JSON dosyasını `serviceAccountKey.json` olarak kaydedin
4. Script'i çalıştırın:
   ```bash
   node clear-pending-admins.js
   ```

### Service Account Key Nasıl Alınır?

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin: `bmt-web-41790`
3. Sol üstteki ⚙️ (Settings) > **Project settings**
4. **Service accounts** sekmesine gidin
5. **Generate new private key** butonuna tıklayın
6. İndirilen JSON dosyasını güvenli bir yerde saklayın
7. **NOT:** Bu dosyayı git'e eklemeyin! `.gitignore`'a ekleyin.

## Yöntem 3: Firebase CLI ile (Basit)

Firebase CLI ile direkt Firestore'dan silme yapılamaz, ama emulator kullanabilirsiniz.

## Güvenlik Uyarısı

⚠️ **ÖNEMLİ:**
- `serviceAccountKey.json` dosyasını **ASLA** git'e eklemeyin!
- Bu dosya projenize tam erişim sağlar
- Dosyayı güvenli bir yerde saklayın
- `.gitignore` dosyasına ekleyin

## Sorun Giderme

### "Permission denied" hatası
- Firestore Security Rules'da `pending_admins` koleksiyonu için silme izni olmalı
- Service account key'in doğru olduğundan emin olun

### "Module not found" hatası
- `npm install firebase-admin` komutunu çalıştırın
- Script'in doğru klasörde olduğundan emin olun

### "Firebase app already initialized" hatası
- Script zaten çalışmış olabilir
- Terminal'i kapatıp tekrar açın

