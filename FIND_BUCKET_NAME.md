# Firebase Storage Bucket Adını Bulma

Bucket bulunamadı hatası aldınız. Doğru bucket adını bulmak için:

## Cloud Shell'de Şu Komutları Çalıştırın:

### 1. Tüm bucket'ları listeleyin:
```bash
gsutil ls
```

### 2. Firebase Storage bucket'ını bulun:
```bash
gsutil ls | grep appspot
```

### 3. Veya Firebase proje bilgilerini kontrol edin:
```bash
gcloud projects describe bmt-web-41790
```

### 4. Firebase Storage bucket adını öğrenmek için:
```bash
gcloud storage buckets list
```

## Alternatif: Firebase Console'dan Kontrol

1. Firebase Console → Storage → Files
2. Üst kısımda bucket adını görebilirsiniz
3. Genellikle şu formatta olur:
   - `bmt-web-41790.appspot.com`
   - veya `bmt-web-41790.firebasestorage.app`

## Doğru Bucket Adını Bulduktan Sonra:

```bash
gsutil cors set cors.json gs://DOGRU-BUCKET-ADI
```

Örnek:
```bash
gsutil cors set cors.json gs://bmt-web-41790.firebasestorage.app
```

