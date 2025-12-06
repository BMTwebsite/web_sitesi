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
  const { to, userEmail, subject, token, link } = data;

  // Email transporter oluştur (Gmail örneği)
  // Not: Gmail için "Daha az güvenli uygulama erişimi" açık olmalı
  // veya OAuth2 kullanmalısınız
  const transporter = nodemailer.createTransport({
    service: 'gmail', // veya başka bir servis (SendGrid, Mailgun, vb.)
    auth: {
      user: 'shylmlk2004@gmail.com', // BMT email adresiniz
      pass: process.env.GMAIL_APP_PASSWORD || 'YOUR_APP_PASSWORD', // Gmail App Password
    },
  });

  // Email içeriği
  const mailOptions = {
    from: '"BMT Web Sitesi" <shylmlk2004@gmail.com>', // Gönderen adı ve email
    to: to,
    replyTo: 'shylmlk2004@gmail.com',
    subject: subject || 'BMT Web Sitesi Onay Maili',
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
          <h2>Admin Hesabı Onayı</h2>
          <p>Merhaba,</p>
          <p><strong>${userEmail || 'Bir kullanıcı'}</strong> e-posta adresi ile BMT Web Sitesi için admin hesabı oluşturma talebi alınmıştır.</p>
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

