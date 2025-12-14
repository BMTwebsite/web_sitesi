// Firebase Cloud Functions - Email Gönderme
// Firebase Extensions - Trigger Email kullanarak
// 
// Bu sistem Firestore'a mail koleksiyonuna doküman ekler
// Firebase Extensions - Trigger Email extension'ı otomatik olarak e-posta gönderir
// 
// Extension Kurulumu:
// 1. Firebase Console > Extensions > Browse > "Trigger Email" arayın
// 2. Extension'ı kurun (SendGrid veya Mailgun seçebilirsiniz)
// 3. API key'leri Firebase Console'dan ayarlayın (kodda şifre yok!)
// 4. Deploy edin: firebase deploy --only functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

// SendGrid API key'i Firebase Functions config'den al
// Kurulum: firebase functions:config:set sendgrid.key="YOUR_API_KEY"
sgMail.setApiKey(functions.config().sendgrid?.key || process.env.SENDGRID_API_KEY || '');

// Email gönderme fonksiyonu - Firebase Extensions (Trigger Email) kullanarak
// Bu fonksiyon Firestore'a mail koleksiyonuna doküman ekler
// Firebase Extensions - Trigger Email extension'ı otomatik olarak e-posta gönderir
// Extension kurulumu: Firebase Console > Extensions > Trigger Email
exports.sendVerificationEmail = functions.https.onCall(async (data, context) => {
  const { to, userEmail, subject, token, link } = data;

  const db = admin.firestore();
  
  // Site adını ve email adresini Firestore'dan al (spam önleme için)
  let siteName = 'BMT Web Sitesi'; // Varsayılan değer
  let siteEmail = null; // Site email adresi (varsa kullanılacak)
  try {
    const siteSettingsDoc = await db.collection('site_settings').doc('main').get();
    if (siteSettingsDoc.exists) {
      const siteSettings = siteSettingsDoc.data();
      if (siteSettings) {
        if (siteSettings.siteName) {
          siteName = siteSettings.siteName;
        }
        if (siteSettings.email) {
          siteEmail = siteSettings.email;
        }
      }
    }
  } catch (error) {
    console.log('Site ayarları alınamadı, varsayılan değerler kullanılıyor:', error);
  }
  
  // Gönderen email adresini belirle (spam önleme için önemli)
  // Site email varsa onu kullan, yoksa site adından email oluştur
  let fromEmail;
  if (siteEmail) {
    // Site email'i varsa onu kullan
    fromEmail = `${siteName} <${siteEmail}>`;
  } else {
    // Site email yoksa, site adını kullanarak email formatı oluştur
    // Firebase domain'ini kullan (noreply yerine site adı)
    const authDomain = functions.config().firebase?.authDomain || 'bmt-web-41790.firebaseapp.com';
    // Site adından geçerli bir email formatı oluştur
    const emailPrefix = siteName.toLowerCase()
      .replace(/[^a-z0-9]/g, '')
      .substring(0, 20) || 'website';
    fromEmail = `${siteName} <${emailPrefix}@${authDomain}>`;
  }
  
  // Email içeriği
  const emailHtml = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          background-color: #2196F3;
          color: white;
          padding: 20px;
          text-align: center;
          border-radius: 5px 5px 0 0;
        }
        .content {
          background-color: #f9f9f9;
          padding: 30px;
          border-radius: 0 0 5px 5px;
        }
        .button {
          display: inline-block;
          padding: 12px 30px;
          background-color: #2196F3;
          color: white;
          text-decoration: none;
          border-radius: 5px;
          margin: 20px 0;
        }
        .footer {
          margin-top: 20px;
          font-size: 12px;
          color: #666;
          text-align: center;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>${siteName}</h1>
      </div>
      <div class="content">
        <h2>Admin Hesabı Onayı</h2>
        <p>Merhaba,</p>
        <p><strong>${userEmail || 'Bir kullanıcı'}</strong> e-posta adresi ile ${siteName} için admin hesabı oluşturma talebi alınmıştır.</p>
        <p>Hesabı aktifleştirmek için aşağıdaki butona tıklayın:</p>
        <p style="text-align: center;">
          <a href="${link}" class="button">Hesabı Onayla</a>
        </p>
        <p>Veya aşağıdaki linki tarayıcınıza yapıştırın:</p>
        <p style="word-break: break-all; color: #2196F3;">${link}</p>
        <p>Bu link 24 saat geçerlidir.</p>
        <p>Eğer bu işlemi siz yapmadıysanız, bu e-postayı görmezden gelebilirsiniz.</p>
      </div>
      <div class="footer">
        <p>Bu e-posta otomatik olarak gönderilmiştir. Lütfen yanıtlamayın.</p>
        <p>&copy; ${new Date().getFullYear()} ${siteName}. Tüm hakları saklıdır.</p>
      </div>
    </body>
    </html>
  `;

  const emailText = `
    ${siteName} - Admin Hesabı Onayı
    
    Merhaba,
    
    ${userEmail || 'Bir kullanıcı'} e-posta adresi ile ${siteName} için admin hesabı oluşturma talebi alınmıştır.
    Hesabı aktifleştirmek için aşağıdaki linke tıklayın:
    
    ${link}
    
    Bu link 24 saat geçerlidir.
    
    Eğer bu işlemi siz yapmadıysanız, bu e-postayı görmezden gelebilirsiniz.
    
    Bu e-posta otomatik olarak gönderilmiştir. Lütfen yanıtlamayın.
  `;

  try {
    console.log('📧 Email gönderme işlemi başlatılıyor...');
    console.log('📬 Alıcı:', to);
    console.log('👤 Kullanıcı email:', userEmail);
    console.log('📝 Konu:', subject || `${siteName} Onay Maili`);
    console.log('🔗 Link:', link);
    console.log('📧 Gönderen:', fromEmail);
    
    // SendGrid API key kontrolü
    const sendGridApiKey = functions.config().sendgrid?.key || process.env.SENDGRID_API_KEY;
    if (!sendGridApiKey) {
      console.warn('⚠️ SendGrid API key bulunamadı, Firestore\'a yazılıyor (Extension kullanılacak)');
      
      // SendGrid yoksa eski yöntemle Firestore'a yaz (Extension için)
      const mailData = {
        to: to,
        message: {
          subject: subject || `${siteName} Onay Maili`,
          html: emailHtml,
          text: emailText,
        },
      };
      
      const docRef = await db.collection('mail').add(mailData);
      console.log('✅ Email Firestore\'a eklendi (Extension gönderecek):', docRef.id);
      
      return { 
        success: true,
        messageId: docRef.id,
        message: 'Email Firestore\'a eklendi, Extension gönderecek'
      };
    }
    
    // SendGrid ile direkt email gönder
    console.log('📤 SendGrid ile direkt email gönderiliyor...');
    
    // From email'i düzelt (SendGrid formatı)
    let sendFromEmail = siteEmail || 'noreply@bmt-web-41790.firebaseapp.com';
    if (fromEmail.includes('<')) {
      // "Site Name <email@domain.com>" formatından email'i çıkar
      const match = fromEmail.match(/<([^>]+)>/);
      if (match) {
        sendFromEmail = match[1];
      }
    }
    
    const msg = {
      to: to,
      from: {
        email: sendFromEmail,
        name: siteName
      },
      subject: subject || `${siteName} Onay Maili`,
      html: emailHtml,
      text: emailText,
      ...(siteEmail && { replyTo: siteEmail }),
    };
    
    console.log('📧 SendGrid mesajı hazırlandı:', {
      to: msg.to,
      from: msg.from,
      subject: msg.subject
    });
    
    await sgMail.send(msg);
    
    console.log('✅ Email SendGrid ile başarıyla gönderildi!');
    console.log('📬 Alıcı:', to);
    
    // Firestore'a da kaydet (log için)
    try {
      await db.collection('mail').add({
        to: to,
        message: {
          subject: subject || `${siteName} Onay Maili`,
          html: emailHtml,
          text: emailText,
        },
        sentVia: 'sendgrid',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (firestoreError) {
      console.warn('⚠️ Firestore\'a kayıt yapılamadı (önemli değil):', firestoreError);
    }
    
    return { 
      success: true,
      message: 'Email başarıyla gönderildi',
      sentVia: 'sendgrid'
    };
  } catch (error) {
    console.error('❌ Email kuyruğa ekleme hatası:', error);
    console.error('📚 Error details:', {
      code: error.code,
      message: error.message,
      stack: error.stack
    });
    
    // Daha detaylı hata mesajı
    let errorMessage = 'Email kuyruğa eklenemedi';
    if (error.code === 'permission-denied') {
      errorMessage = 'Firestore yazma izni yok. Firestore Security Rules\'ı kontrol edin.';
    } else if (error.message) {
      errorMessage = error.message;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      errorMessage,
      {
        code: error.code,
        message: error.message,
        originalError: error.toString()
      }
    );
  }
});
