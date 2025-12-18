# Firebase Storage CORS Ayarları - PowerShell Script
# Proje ID: bmt-web-41790

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Firebase Storage CORS Ayarları" -ForegroundColor Cyan
Write-Host "Proje: bmt-web-41790" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# CORS JSON dosyasını oluştur
$corsJson = @'
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600
  }
]
'@

Write-Host "CORS ayarları dosyası oluşturuluyor..." -ForegroundColor Yellow
$corsJson | Out-File -FilePath "cors.json" -Encoding UTF8

Write-Host "✅ cors.json dosyası oluşturuldu" -ForegroundColor Green
Write-Host ""

# gsutil kontrolü
Write-Host "gsutil kontrol ediliyor..." -ForegroundColor Yellow
$gsutilPath = Get-Command gsutil -ErrorAction SilentlyContinue

if (-not $gsutilPath) {
    Write-Host "❌ gsutil bulunamadı!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Google Cloud SDK yüklü değil. İki seçeneğiniz var:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Google Cloud SDK'yı yükleyin:" -ForegroundColor Cyan
    Write-Host "   https://cloud.google.com/sdk/docs/install" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Google Cloud Shell kullanın (Önerilen):" -ForegroundColor Cyan
    Write-Host "   https://console.cloud.google.com/storage/browser?project=bmt-web-41790" -ForegroundColor White
    Write-Host "   Cloud Shell'i açın ve şu komutları çalıştırın:" -ForegroundColor White
    Write-Host "   gsutil cors set cors.json gs://bmt-web-41790.appspot.com" -ForegroundColor Green
    Write-Host ""
    Write-Host "cors.json dosyası hazır. Google Cloud Shell'de kullanabilirsiniz." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ gsutil bulundu" -ForegroundColor Green
Write-Host ""

# CORS ayarlarını uygula
Write-Host "CORS ayarları uygulanıyor..." -ForegroundColor Yellow
Write-Host "Bucket: gs://bmt-web-41790.appspot.com" -ForegroundColor White
Write-Host ""

try {
    $result = & gsutil cors set cors.json gs://bmt-web-41790.appspot.com 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ CORS ayarları başarıyla uygulandı!" -ForegroundColor Green
        Write-Host ""
        
        # Doğrulama
        Write-Host "CORS ayarları doğrulanıyor..." -ForegroundColor Yellow
        & gsutil cors get gs://bmt-web-41790.appspot.com
        Write-Host ""
        Write-Host "✅ Tamamlandı! Görselleriniz artık web uygulamanızda görünecek." -ForegroundColor Green
        Write-Host ""
        Write-Host "Not: Değişikliklerin etkili olması birkaç dakika sürebilir." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Hata oluştu:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        Write-Host ""
        Write-Host "Alternatif: Google Cloud Shell kullanın:" -ForegroundColor Yellow
        Write-Host "https://console.cloud.google.com/storage/browser?project=bmt-web-41790" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Hata: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternatif: Google Cloud Shell kullanın:" -ForegroundColor Yellow
    Write-Host "https://console.cloud.google.com/storage/browser?project=bmt-web-41790" -ForegroundColor White
}

