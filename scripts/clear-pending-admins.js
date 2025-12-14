/**
 * Bekleyen Admin Kayıtlarını Temizleme Scripti
 * 
 * Bu script, admin girişi olmadan pending_admins koleksiyonundaki
 * tüm bekleyen admin kayıtlarını siler.
 * 
 * Kullanım:
 *   node scripts/clear-pending-admins.js
 * 
 * Gereksinimler:
 *   - Firebase Admin SDK yüklü olmalı
 *   - Firebase service account key dosyası gerekli (opsiyonel - environment variable ile de çalışır)
 */

const admin = require('firebase-admin');

// Firebase yapılandırması
// Eğer GOOGLE_APPLICATION_CREDENTIALS environment variable set edilmişse otomatik kullanılır
// Aksi halde serviceAccountKey.json dosyası gerekli

let app;
try {
  // Önce environment variable'dan deneyelim
  app = admin.app();
} catch (e) {
  // Firebase initialize edilmemiş, initialize edelim
  try {
    // Service account key dosyası varsa kullan
    const serviceAccount = require('../serviceAccountKey.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    app = admin.app();
  } catch (err) {
    // Environment variable kullan
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
    app = admin.app();
  }
}

const db = admin.firestore();

async function clearPendingAdmins() {
  console.log('🔄 Bekleyen admin kayıtları temizleniyor...\n');
  
  try {
    // Tüm pending_admins dokümanlarını al
    const snapshot = await db.collection('pending_admins').get();
    
    if (snapshot.empty) {
      console.log('✅ Bekleyen admin kaydı bulunamadı.');
      process.exit(0);
    }
    
    console.log(`📋 ${snapshot.size} adet bekleyen admin kaydı bulundu.\n`);
    
    // Batch delete (Firestore batch limit: 500)
    const batchSize = 500;
    let deletedCount = 0;
    
    for (let i = 0; i < snapshot.docs.length; i += batchSize) {
      const batch = db.batch();
      const end = Math.min(i + batchSize, snapshot.docs.length);
      
      for (let j = i; j < end; j++) {
        batch.delete(snapshot.docs[j].ref);
        deletedCount++;
      }
      
      await batch.commit();
      console.log(`✅ ${deletedCount}/${snapshot.size} kayıt silindi...`);
    }
    
    console.log(`\n🎉 Başarılı! Toplam ${deletedCount} adet bekleyen admin kaydı silindi.`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Hata:', error.message);
    console.error('\nDetaylar:', error);
    process.exit(1);
  }
}

// Script'i çalıştır
clearPendingAdmins();

