# Gmail App Password Oluşturma ve Güncelleme

## Sorun
Gmail kimlik doğrulama hatası alıyorsunuz: "Username and Password not accepted"

## Çözüm: Yeni Gmail App Password Oluşturun

### Adım 1: Google Hesabınıza Gidin
1. https://myaccount.google.com adresine gidin
2. Giriş yapın (suheyla0403@gmail.com)

### Adım 2: 2 Adımlı Doğrulama Kontrolü
1. Sol menüden **Güvenlik** sekmesine tıklayın
2. **2 Adımlı Doğrulama** bölümünü bulun
3. Eğer aktif değilse, **Aktifleştir** butonuna tıklayın ve kurulumu tamamlayın

### Adım 3: Uygulama Şifresi Oluşturun
1. **2 Adımlı Doğrulama** sayfasında aşağı kaydırın
2. **Uygulama şifreleri** bölümünü bulun
3. **Uygulama şifreleri** linkine tıklayın
4. Eğer eski şifreler varsa, hepsini **Sil** butonuna tıklayarak silin
5. **Uygulama seçin** dropdown'ından **Mail** seçin
6. **Cihaz seçin** dropdown'ından **Diğer (Özel ad)** seçin
7. İsim olarak **Firebase Functions** yazın
8. **Oluştur** butonuna tıklayın
9. **16 haneli şifreyi kopyalayın** (örnek: `abcd efgh ijkl mnop`)

### Adım 4: Şifreyi Firebase'e Ekleyin

Terminal'de şu komutu çalıştırın (şifreyi boşluksuz yazın):

```powershell
firebase functions:config:set gmail.user="suheyla0403@gmail.com" gmail.password="yoaiowvtkuqhmjpp"
```

**ÖNEMLİ:** 
- Şifreyi boşluksuz yazın (örnek: `abcdefghijklmnop`)
- Tırnak işaretlerini unutmayın
- Şifreyi doğru kopyaladığınızdan emin olun

### Adım 5: Functions'ı Deploy Edin

```powershell
firebase deploy --only functions:sendVerificationEmail --force
```

### Adım 6: Test Edin
1. Yeni bir admin kaydı yapın
2. Email'in gelip gelmediğini kontrol edin

## Sorun Devam Ederse

1. **Gmail hesabınızda "Daha az güvenli uygulama erişimi" kontrolü:**
   - Google Hesabı > Güvenlik > Daha az güvenli uygulama erişimi
   - Bu özellik artık kullanılmıyor, sadece App Password kullanın

2. **Yeni bir Gmail hesabı deneyin:**
   - Farklı bir Gmail hesabı ile App Password oluşturun
   - Config'i güncelleyin

3. **Firebase Console'dan Environment Variables kullanın:**
   - Firebase Console > Functions > Configuration > Environment variables
   - `GMAIL_USER` ve `GMAIL_APP_PASSWORD` ekleyin
   - Functions'ı yeniden deploy edin

## Notlar

- App Password'lar 16 karakter uzunluğundadır
- Boşluklu veya boşluksuz kullanılabilir (kodda trim() var)
- Her App Password sadece bir kez görüntülenir, kaydedin
- App Password'ları güvenli tutun, paylaşmayın

