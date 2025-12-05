// Firebase Cloud Functions - Email Gönderme
// Bu dosyayı Firebase Functions klasörüne ekleyin ve deploy edin
// 
// Kurulum:
// 1. Firebase CLI'yi yükleyin: npm install -g firebase-tools
// 2. Firebase'e giriş yapın: firebase login
// 3. Projeyi başlatın: firebase init functions
// 4. Bu dosyayı functions/index.js olarak kaydedin
// 5. Deploy edin: firebase deploy --only functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Email gönderme fonksiyonu
exports.sendVerificationEmail = functions.https.onCall(async (data, context) => {
  const { to, userEmail, subject, token, link, rejectLink } = data;

  // Email transporter oluştur (Gmail örneği)
  // Spam'a gitmemesi için doğru ayarlar
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'bmtbanu@gmail.com', // BMT email adresiniz
      pass: process.env.GMAIL_APP_PASSWORD || 'YOUR_APP_PASSWORD', // Gmail App Password (environment variable kullanın)
    },
    // Spam'a gitmemesi için ek ayarlar
    tls: {
      rejectUnauthorized: false
    },
    // Rate limiting
    pool: true,
    maxConnections: 1,
    maxMessages: 3,
  });

  // Email içeriği - Spam'a gitmemesi için optimize edilmiş
  const mailOptions = {
    from: '"BMT Web Sitesi" <bmtbanu@gmail.com>', // Gönderen adı ve email
    to: to,
    replyTo: 'bmtbanu@gmail.com', // Yanıt adresi
    subject: subject || 'BMT Web Sitesi - Admin Hesabı Onay İsteği',
    // Spam'a gitmemesi için headers
    headers: {
      'X-Priority': '1',
      'X-MSMail-Priority': 'High',
      'Importance': 'high',
      'List-Unsubscribe': '<mailto:bmtbanu@gmail.com>',
    },
    // Email önceliği
    priority: 'high',
    html: `
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
          <h1>BMT Web Sitesi</h1>
        </div>
        <div class="content">
          <h2>Admin Hesabı Onay İsteği</h2>
          <p>Merhaba,</p>
          <p><strong>${userEmail || 'Bir kullanıcı'}</strong> e-posta adresi ile BMT Web Sitesi için admin hesabı oluşturma talebi alınmıştır.</p>
          <p style="text-align: center; margin: 30px 0;">
            <a href="${link}" class="button" style="text-decoration: none; background-color: #4CAF50; margin-right: 10px;">✅ Onayla</a>
            <a href="${rejectLink}" class="button" style="text-decoration: none; background-color: #F44336; margin-left: 10px;">❌ Reddet</a>
          </p>
          <p style="color: #666; font-size: 12px; margin-top: 20px;">Onaylamak için yeşil butona, reddetmek için kırmızı butona tıklayın.</p>
          <p style="color: #666; font-size: 12px;">Veya aşağıdaki linkleri kullanabilirsiniz:</p>
          <p style="word-break: break-all; color: #2196F3; font-size: 11px; margin: 5px 0;"><strong>Onay:</strong> ${link}</p>
          <p style="word-break: break-all; color: #F44336; font-size: 11px; margin: 5px 0;"><strong>Red:</strong> ${rejectLink}</p>
          <p style="color: #666; font-size: 12px; margin-top: 15px;">Bu linkler 24 saat geçerlidir.</p>
        </div>
        <div class="footer">
          <p>Bu e-posta otomatik olarak gönderilmiştir. Lütfen yanıtlamayın.</p>
          <p>&copy; ${new Date().getFullYear()} BMT Web Sitesi. Tüm hakları saklıdır.</p>
        </div>
      </body>
      </html>
    `,
    text: `
      BMT Web Sitesi - Admin Hesabı Onayı
      
      Merhaba,
      
      ${userEmail || 'Bir kullanıcı'} e-posta adresi ile BMT Web Sitesi için admin hesabı oluşturma talebi alınmıştır.
      Hesabı aktifleştirmek için aşağıdaki linke tıklayın:
      
      ${link}
      
      Bu link 24 saat geçerlidir.
      
      Eğer bu işlemi siz yapmadıysanız, bu e-postayı görmezden gelebilirsiniz.
      
      Bu e-posta otomatik olarak gönderilmiştir. Lütfen yanıtlamayın.
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Email gönderme hatası:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Email gönderilemedi',
      error.message
    );
  }
});

