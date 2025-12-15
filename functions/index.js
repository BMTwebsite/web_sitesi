// Firebase Cloud Functions - Email Gönderme
// Gmail SMTP kullanarak direkt email gönderir
// 
// Kurulum:
// 1. Gmail App Password oluşturun (Google Hesabınız > Güvenlik > 2 Adımlı Doğrulama > Uygulama şifreleri)
// 2. Firebase Console > Functions > Configuration > Environment variables
// 3. GMAIL_USER ve GMAIL_APP_PASSWORD değişkenlerini ekleyin
// 4. Deploy edin: firebase deploy --only functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const { Resend } = require('resend');

admin.initializeApp();

// Gmail SMTP transporter oluştur
// Environment variables'dan Gmail bilgilerini al
const createTransporter = () => {
  try {
    console.log('🔍 Gmail bilgileri alınıyor...');
    
    // Önce environment variables'dan dene (Google Cloud Console'dan ayarlanan)
    let gmailUser = process.env.GMAIL_USER;
    let gmailPassword = process.env.GMAIL_APP_PASSWORD;
    
    console.log('📦 Environment variables kontrol:');
    console.log('   GMAIL_USER:', gmailUser ? 'VAR' : 'YOK');
    console.log('   GMAIL_APP_PASSWORD:', gmailPassword ? 'VAR' : 'YOK');
    
    // Eğer environment variable'da yoksa, functions.config()'den dene
    if (!gmailUser || !gmailPassword) {
      console.log('📦 functions.config() kontrol ediliyor...');
      try {
        const config = functions.config();
        console.log('📦 Config objesi:', config ? 'VAR' : 'YOK');
        if (config) {
          console.log('📦 Config keys:', Object.keys(config));
          if (config.gmail) {
            console.log('📦 Config.gmail:', config.gmail ? 'VAR' : 'YOK');
            if (config.gmail) {
              console.log('📦 Config.gmail keys:', Object.keys(config.gmail));
              gmailUser = gmailUser || config.gmail.user;
              gmailPassword = gmailPassword || config.gmail.password;
              console.log('📦 Config\'den alındı:');
              console.log('   User:', gmailUser ? `${gmailUser.substring(0, 5)}***` : 'YOK');
              console.log('   Password:', gmailPassword ? 'VAR (' + gmailPassword.length + ' karakter)' : 'YOK');
            }
          } else {
            console.warn('⚠️ Config.gmail bulunamadı!');
          }
        }
      } catch (configError) {
        console.error('❌ functions.config() hatası:', configError);
        console.error('📚 Error details:', {
          message: configError.message,
          stack: configError.stack
        });
      }
    }
    
    console.log('🔍 Final Gmail bilgileri:');
    console.log('📧 Gmail User:', gmailUser ? `${gmailUser.substring(0, 5)}*** (${gmailUser.length} karakter)` : 'BULUNAMADI');
    console.log('🔑 Gmail Password:', gmailPassword ? `VAR (${gmailPassword.length} karakter)` : 'BULUNAMADI');
    
    if (!gmailUser || !gmailPassword) {
      console.error('❌ Gmail bilgileri bulunamadı!');
      console.error('💡 Gmail bilgilerini ayarlamak için:');
      console.error('   Terminal: firebase functions:config:set gmail.user="your-email@gmail.com" gmail.password="your-app-password"');
      console.error('   Sonra: firebase deploy --only functions');
      return null;
    }
    
    // Trim ve kontrol
    const trimmedUser = gmailUser.trim();
    const trimmedPassword = gmailPassword.trim();
    
    console.log('🔍 Trimmed bilgiler:');
    console.log('📧 User:', trimmedUser.substring(0, 5) + '*** (' + trimmedUser.length + ' karakter)');
    console.log('🔑 Password:', trimmedPassword.length + ' karakter');
    
    // Nodemailer transporter oluştur
    console.log('📤 Nodemailer transporter oluşturuluyor...');
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: trimmedUser,
        pass: trimmedPassword
      }
    });
    
    console.log('✅ Transporter oluşturuldu');
    return transporter;
  } catch (error) {
    console.error('❌ Transporter oluşturma hatası:', error);
    console.error('📚 Error details:', {
      message: error.message,
      stack: error.stack
    });
    return null;
  }
};

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
    
    // Gönderen email adresini belirle
    let sendFromEmail = siteEmail || 'onay@bmt.edu.tr'; // Varsayılan email
    let sendFromName = siteName;
    
    // Resend'i geçici olarak devre dışı bırak (verified domain gerekli)
    // Önce Resend'i dene (daha güvenilir)
    const resendApiKey = process.env.RESEND_API_KEY || functions.config()?.resend?.api_key;
    const useResend = false; // Geçici olarak devre dışı - verified domain gerekli
    
    if (resendApiKey && useResend) {
      console.log('📤 Resend API ile email gönderiliyor...');
      console.log('🔑 Resend API Key:', resendApiKey.substring(0, 10) + '***');
      console.log('📧 From:', `${sendFromName} <${sendFromEmail}>`);
      console.log('📬 To:', to);
      
      try {
        const resend = new Resend(resendApiKey);
        
        const result = await resend.emails.send({
          from: `${sendFromName} <${sendFromEmail}>`,
          to: to,
          subject: subject || `${siteName} Onay Maili`,
          html: emailHtml,
          text: emailText,
          ...(siteEmail && { reply_to: siteEmail }),
        });
        
        console.log('📥 Resend response:', JSON.stringify(result, null, 2));
        console.log('📧 Result data:', result.data);
        console.log('📧 Result error:', result.error);
        
        if (result.error) {
          console.error('❌ Resend API hatası:', result.error);
          throw new Error(`Resend API hatası: ${JSON.stringify(result.error)}`);
        }
        
        if (!result.data || !result.data.id) {
          console.error('❌ Resend response\'da data veya id yok!');
          console.error('📥 Full response:', result);
          throw new Error('Resend API\'den geçersiz yanıt alındı');
        }
        
        console.log('✅ Email Resend ile başarıyla gönderildi!');
        console.log('📧 Message ID:', result.data.id);
        
        // Firestore'a log olarak kaydet
        try {
          await db.collection('mail_logs').add({
            to: to,
            subject: subject || `${siteName} Onay Maili`,
            messageId: result.data.id || 'unknown',
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'sent',
            via: 'resend',
          });
        } catch (firestoreError) {
          console.warn('⚠️ Firestore log kaydı yapılamadı (önemli değil):', firestoreError);
        }
        
        return {
          success: true,
          messageId: result.data.id,
          message: 'Email başarıyla gönderildi',
          sentVia: 'resend'
        };
      } catch (resendError) {
        console.error('❌ Resend hatası:', resendError);
        console.error('📚 Error details:', {
          message: resendError.message,
          stack: resendError.stack,
          response: resendError.response
        });
        console.log('🔄 Gmail SMTP\'ye geçiliyor...');
        // Resend başarısız olursa Gmail'e geç
      }
    }
    
    // Gmail SMTP transporter oluştur (fallback)
    console.log('📤 Gmail SMTP ile email gönderiliyor...');
    const transporter = createTransporter();
    
    if (!transporter) {
      throw new Error('Email servisi yapılandırılamadı. Resend API key veya Gmail bilgileri eksik.');
    }
    
    // Gmail kullanırken "from" adresi MUTLAKA Gmail user olmalı
    // App Password'un oluşturulduğu hesap ile aynı olmalı
    let gmailUser = process.env.GMAIL_USER;
    if (!gmailUser) {
      try {
        const config = functions.config();
        if (config && config.gmail && config.gmail.user) {
          gmailUser = config.gmail.user;
        }
      } catch (configError) {
        console.warn('⚠️ functions.config() hatası:', configError);
      }
    }
    
    if (!gmailUser) {
      throw new Error('Gmail user bulunamadı. GMAIL_USER ayarlanmalı.');
    }
    
    // Gmail için "from" adresi Gmail user olmalı (App Password ile aynı hesap)
    sendFromEmail = gmailUser;
    console.log('📧 Gmail "from" adresi (App Password ile aynı hesap):', sendFromEmail);
    
    console.log('📧 Mail options:');
    console.log('   From:', `${sendFromName} <${sendFromEmail}>`);
    console.log('   To:', to);
    console.log('   Subject:', subject || `${siteName} Onay Maili`);
    
    const mailOptions = {
      from: `${sendFromName} <${sendFromEmail}>`,
      to: to,
      subject: subject || `${siteName} Onay Maili`,
      html: emailHtml,
      text: emailText,
      ...(siteEmail && { replyTo: siteEmail }),
    };
    
    console.log('📤 Nodemailer sendMail çağrılıyor...');
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email Gmail SMTP ile başarıyla gönderildi!');
    console.log('📧 Message ID:', info.messageId);
    
    // Firestore'a log olarak kaydet
    try {
      await db.collection('mail_logs').add({
        to: to,
        subject: subject || `${siteName} Onay Maili`,
        messageId: info.messageId,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'sent',
        via: 'gmail-smtp',
      });
    } catch (firestoreError) {
      console.warn('⚠️ Firestore log kaydı yapılamadı (önemli değil):', firestoreError);
    }
    
    return { 
      success: true,
      messageId: info.messageId,
      message: 'Email başarıyla gönderildi',
      sentVia: 'gmail-smtp'
    };
  } catch (error) {
    console.error('❌ Email gönderme hatası:', error);
    console.error('📚 Error details:', {
      code: error.code,
      message: error.message,
      stack: error.stack,
      response: error.response, // Nodemailer hataları için
      responseCode: error.responseCode,
      command: error.command
    });
    
    // Gmail kimlik doğrulama hatası için özel mesaj
    if (error.code === 'EAUTH' || error.message?.includes('Invalid login') || error.message?.includes('Username and Password not accepted')) {
      console.error('🔐 Gmail kimlik doğrulama hatası tespit edildi!');
      console.error('💡 Kontrol edilmesi gerekenler:');
      console.error('   1. Gmail App Password doğru mu?');
      console.error('   2. Gmail hesabında 2 Adımlı Doğrulama aktif mi?');
      console.error('   3. App Password silinmiş veya değiştirilmiş olabilir mi?');
      console.error('   4. Config doğru yüklendi mi? (functions:config:get ile kontrol edin)');
      
      // Config'i tekrar kontrol et
      try {
        const config = functions.config();
        console.error('📦 Mevcut config:');
        console.error('   gmail.user:', config?.gmail?.user ? config.gmail.user.substring(0, 5) + '***' : 'YOK');
        console.error('   gmail.password:', config?.gmail?.password ? config.gmail.password.length + ' karakter' : 'YOK');
      } catch (configError) {
        console.error('⚠️ Config kontrol edilemedi:', configError);
      }
    }
    
    // Daha detaylı hata mesajı
    let errorMessage = 'Email gönderilemedi';
    if (error.code === 'EAUTH' || error.message?.includes('Invalid login') || error.message?.includes('Username and Password not accepted')) {
      errorMessage = 'Gmail kimlik doğrulama hatası. Gmail App Password\'u kontrol edin. Yeni bir App Password oluşturmayı deneyin.';
    } else if (error.code === 'permission-denied') {
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
        originalError: error.toString(),
        response: error.response
      }
    );
  }
});

// HTTP endpoint - Admin onay işlemi (email'deki link buraya yönlendirilecek)
exports.verifyAdmin = functions.https.onRequest(async (req, res) => {
  const token = req.query.token || req.body.token;
  
  console.log('🔍 verifyAdmin HTTP endpoint çağrıldı');
  console.log('🔑 Token:', token);
  
  if (!token) {
    console.error('❌ Token bulunamadı');
    res.status(400).send(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Onay Hatası</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #0A1929;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
          }
          .container {
            text-align: center;
            padding: 40px;
            background-color: #1A2332;
            border-radius: 10px;
            max-width: 500px;
          }
          h1 { color: #F44336; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>❌ Onay Hatası</h1>
          <p>Geçersiz onay linki. Token bulunamadı.</p>
          <p>Lütfen email'deki linki tekrar kontrol edin.</p>
        </div>
      </body>
      </html>
    `);
    return;
  }
  
  const db = admin.firestore();
  
  try {
    console.log('🔍 Token doğrulanıyor: $token');
    
    // Pending admin'i bul
    const query = await db.collection('pending_admins')
      .where('token', '==', token)
      .where('verified', '==', false)
      .limit(1)
      .get();
    
    if (query.empty) {
      console.error('❌ Geçersiz veya kullanılmış token');
      res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>Onay Hatası</title>
          <style>
            body {
              font-family: Arial, sans-serif;
              background-color: #0A1929;
              color: white;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              margin: 0;
            }
            .container {
              text-align: center;
              padding: 40px;
              background-color: #1A2332;
              border-radius: 10px;
              max-width: 500px;
            }
            h1 { color: #F44336; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>❌ Onay Hatası</h1>
            <p>Geçersiz veya kullanılmış onay linki.</p>
            <p>Lütfen yeni bir kayıt yapın veya admin panelinden manuel onay isteyin.</p>
          </div>
        </body>
        </html>
      `);
      return;
    }
    
    const doc = query.docs[0];
    const data = doc.data();
    const email = data.email;
    const password = data.password;
    const firstName = data.firstName || '';
    const lastName = data.lastName || '';
    
    console.log('✅ Admin bulundu:', email);
    
    // Admin'i onayla
    const existingAdminQuery = await db.collection('admins')
      .where('email', '==', email)
      .limit(1)
      .get();
    
    const batch = db.batch();
    
    // Pending admin'i verified olarak işaretle
    batch.update(doc.ref, { verified: true });
    
    // Admin zaten yoksa ekle
    if (existingAdminQuery.empty) {
      const adminRef = db.collection('admins').doc();
      batch.set(adminRef, {
        firstName: firstName,
        lastName: lastName,
        email: email,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // Admin varsa firstName ve lastName'i güncelle
      const existingDoc = existingAdminQuery.docs[0];
      const updateData = {};
      if (firstName) updateData.firstName = firstName;
      if (lastName) updateData.lastName = lastName;
      if (Object.keys(updateData).length > 0) {
        batch.update(existingDoc.ref, updateData);
      }
    }
    
    await batch.commit();
    console.log('✅ Admin onaylandı ve admins koleksiyonuna eklendi');
    
    // Firebase Auth'da kullanıcı oluştur veya giriş yap
    try {
      // Önce kullanıcıyı oluşturmayı dene
      await admin.auth().createUser({
        email: email,
        password: password,
        emailVerified: true,
      });
      console.log('✅ Firebase Auth kullanıcısı oluşturuldu');
    } catch (authError) {
      if (authError.code === 'auth/email-already-exists') {
        console.log('ℹ️ Kullanıcı zaten mevcut, güncelleniyor...');
        // Kullanıcı zaten varsa, şifresini güncelle
        const user = await admin.auth().getUserByEmail(email);
        await admin.auth().updateUser(user.uid, {
          password: password,
          emailVerified: true,
        });
        console.log('✅ Firebase Auth kullanıcısı güncellendi');
      } else {
        console.warn('⚠️ Firebase Auth hatası (önemli değil):', authError);
      }
    }
    
    // Başarılı HTML sayfası gönder
    res.status(200).send(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Hesap Onaylandı</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #0A1929;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
          }
          .container {
            text-align: center;
            padding: 40px;
            background-color: #1A2332;
            border-radius: 10px;
            max-width: 500px;
          }
          h1 { color: #4CAF50; }
          .success-icon {
            font-size: 80px;
            color: #4CAF50;
            margin-bottom: 20px;
          }
          .button {
            display: inline-block;
            padding: 12px 30px;
            background-color: #2196F3;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 20px;
          }
          .button:hover {
            background-color: #1976D2;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="success-icon">✓</div>
          <h1>Hesap Onaylandı!</h1>
          <p>Hesabınız başarıyla onaylandı.</p>
          <p>Artık giriş yapabilirsiniz.</p>
          <a href="https://${process.env.GCLOUD_PROJECT || 'bmt-web-41790'}.firebaseapp.com/#/admin-login" class="button">Giriş Yap</a>
        </div>
      </body>
      </html>
    `);
    
  } catch (error) {
    console.error('❌ Onay hatası:', error);
    res.status(500).send(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Onay Hatası</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #0A1929;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
          }
          .container {
            text-align: center;
            padding: 40px;
            background-color: #1A2332;
            border-radius: 10px;
            max-width: 500px;
          }
          h1 { color: #F44336; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>❌ Onay Hatası</h1>
          <p>Onay işlemi sırasında bir hata oluştu.</p>
          <p>Lütfen daha sonra tekrar deneyin veya admin panelinden manuel onay isteyin.</p>
        </div>
      </body>
      </html>
    `);
  }
});
