import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  
  FirestoreService() : _firestore = FirebaseFirestore.instance {
    // Web için Firestore ayarları
    if (kIsWeb) {
      _firestore.settings = const Settings(
        persistenceEnabled: false, // Web'de persistence sorun çıkarabilir
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }
  final String _eventsCollection = 'events';
  final String _pendingAdminsCollection = 'pending_admins';
  final String _adminsCollection = 'admins';
  final String _contactSettingsCollection = 'contact_settings';
  final String _contactSettingsDocId = 'main';


  // Get all events
  Stream<List<EventData>> getEvents() {
    return _firestore
        .collection(_eventsCollection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventData.fromFirestore(doc))
          .toList();
    });
  }

  // Add event
  Future<void> addEvent(EventData event) async {
    await _firestore.collection(_eventsCollection).add(event.toMap());
  }

  // Update event
  Future<void> updateEvent(String eventId, EventData event) async {
    await _firestore
        .collection(_eventsCollection)
        .doc(eventId)
        .update(event.toMap());
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_eventsCollection).doc(eventId).delete();
  }


  // Register pending admin
  Future<String> registerPendingAdmin(String email, String password) async {
    try {
      print('🔍 Mevcut admin kontrolü yapılıyor...');
      // Check if admin already exists with timeout
      final existingAdmin = await _firestore
          .collection(_adminsCollection)
          .where('email', isEqualTo: email)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Admin kontrolü timeout oldu');
              throw 'Bağlantı zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.';
            },
          );
      
      if (existingAdmin.docs.isNotEmpty) {
        print('❌ Bu e-posta adresi zaten kayıtlı');
        throw 'Bu e-posta adresi zaten kayıtlı.';
      }

      print('🔍 Bekleyen admin kontrolü yapılıyor...');
      // Check if already pending with timeout
      final existingPending = await _firestore
          .collection(_pendingAdminsCollection)
          .where('email', isEqualTo: email)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Bekleyen admin kontrolü timeout oldu');
              throw 'Bağlantı zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.';
            },
          );
      
      if (existingPending.docs.isNotEmpty) {
        print('❌ Bu e-posta için zaten bekleyen bir kayıt var');
        throw 'Bu e-posta adresi için zaten bir onay talebi mevcut. Lütfen e-postanızı kontrol edin.';
      }

      print('🔑 Token oluşturuluyor...');
      // Generate verification token
      final token = DateTime.now().millisecondsSinceEpoch.toString() +
          email.hashCode.toString();

      print('💾 Firestore\'a kayıt yapılıyor...');
      print('📋 Kayıt verisi: email=$email, token=$token');
      print('🔧 Firestore instance: ${_firestore.app.name}');
      print('🔧 Collection path: $_pendingAdminsCollection');
      
      // Test Firestore bağlantısı
      try {
        print('🧪 Firestore bağlantı testi yapılıyor...');
        await _firestore.collection('_test').limit(1).get().timeout(
          const Duration(seconds: 5),
        );
        print('✅ Firestore bağlantısı çalışıyor');
      } catch (e) {
        print('⚠️ Firestore bağlantı testi hatası: $e');
        // Devam et, test başarısız olsa bile kayıt denemesi yapılacak
      }
      
      // Add to pending admins with timeout
      print('📝 Doküman ekleniyor...');
      final docRef = await _firestore.collection(_pendingAdminsCollection).add({
        'email': email,
        'password': password, // Note: In production, hash this password
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'verified': false,
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          print('⏱️ Firestore yazma işlemi timeout oldu');
          print('💡 Muhtemel nedenler:');
          print('   1. Firestore Security Rules yazma izni vermiyor');
          print('   2. İnternet bağlantısı sorunu');
          print('   3. Firebase proje ayarları');
          throw 'Kayıt işlemi zaman aşımına uğradı.\n\n'
              'Lütfen şunları kontrol edin:\n'
              '1. Firebase Console > Firestore Database > Rules\n'
              '2. pending_admins koleksiyonu için yazma izni verilmiş olmalı\n'
              '3. İnternet bağlantınızı kontrol edin';
        },
      );

      print('✅ Firestore kaydı başarılı! Document ID: ${docRef.id}');
      print('📊 Firebase konsolunda kontrol edin: pending_admins koleksiyonu');
      return token;
    } on FirebaseException catch (e) {
      print('❌ FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase konsolunda Firestore Security Rules\'ı kontrol edin:\n\n'
            'pending_admins koleksiyonu için yazma izni verilmelidir.\n'
            'Örnek rule:\n'
            'match /pending_admins/{document=**} {\n'
            '  allow write: if true; // Geçici olarak tüm yazmalara izin ver\n'
            '}';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Firestore hatası: ${e.message}';
      }
    } catch (e) {
      print('❌ FirestoreService.registerPendingAdmin hatası: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw 'Firestore izin hatası. Lütfen Firebase konsolunda gerekli izinlerin ayarlandığından emin olun.';
      }
      rethrow;
    }
  }

  // Verify admin by token
  Future<Map<String, String>> verifyAdmin(String token) async {
    final query = await _firestore
        .collection(_pendingAdminsCollection)
        .where('token', isEqualTo: token)
        .where('verified', isEqualTo: false)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw 'Geçersiz veya kullanılmış onay linki.';
    }

    final doc = query.docs.first;
    final data = doc.data();
    final email = data['email'] as String;
    final password = data['password'] as String;

    // Mark as verified
    await doc.reference.update({'verified': true});

    // Move to admins collection
    await _firestore.collection(_adminsCollection).add({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return {'email': email, 'password': password};
  }

  // Reject admin by token (delete from pending_admins)
  Future<void> rejectAdmin(String token) async {
    final query = await _firestore
        .collection(_pendingAdminsCollection)
        .where('token', isEqualTo: token)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw 'Geçersiz veya kullanılmış red linki.';
    }

    final doc = query.docs.first;
    await doc.reference.delete();
  }

  // Delete all pending admin registrations
  Future<int> deleteAllPendingAdmins() async {
    try {
      final query = await _firestore
          .collection(_pendingAdminsCollection)
          .get();
      
      int deletedCount = 0;
      for (var doc in query.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
      
      return deletedCount;
    } catch (e) {
      print('❌ Tüm bekleyen admin kayıtlarını silme hatası: $e');
      rethrow;
    }
  }

  // Check if admin is verified
  Future<bool> isAdminVerified(String email) async {
    final query = await _firestore
        .collection(_adminsCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    return query.docs.isNotEmpty;
  }

  // Get contact settings
  Future<Map<String, dynamic>> getContactSettings() async {
    final doc = await _firestore
        .collection(_contactSettingsCollection)
        .doc(_contactSettingsDocId)
        .get();
    
    if (!doc.exists) {
      // Return default values if document doesn't exist
      return {
        'email': 'info@bmt.edu.tr',
        'socialMedia': [
          {
            'name': 'Instagram',
            'icon': 'camera_alt',
            'url': 'https://www.instagram.com/banubmt?igsh=MmtvemV2YWtqYzVu',
            'color': '#E4405F',
          },
          {
            'name': 'LinkedIn',
            'icon': 'business',
            'url': 'https://www.linkedin.com/company/banubmt/',
            'color': '#0077B5',
          },
          {
            'name': 'YouTube',
            'icon': 'play_circle_filled',
            'url': 'https://youtube.com/@banubmt?si=w6Qi4NEKYoOmUZmz',
            'color': '#FF0000',
          },
          {
            'name': 'TikTok',
            'icon': 'music_note',
            'url': 'https://www.tiktok.com/@banubmt',
            'color': '#000000',
          },
        ],
      };
    }
    
    return doc.data()!;
  }

  // Stream contact settings
  Stream<Map<String, dynamic>> getContactSettingsStream() {
    return _firestore
        .collection(_contactSettingsCollection)
        .doc(_contactSettingsDocId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {
          'email': 'info@bmt.edu.tr',
          'socialMedia': [
            {
              'name': 'Instagram',
              'icon': 'camera_alt',
              'url': 'https://www.instagram.com/banubmt?igsh=MmtvemV2YWtqYzVu',
              'color': '#E4405F',
            },
            {
              'name': 'LinkedIn',
              'icon': 'business',
              'url': 'https://www.linkedin.com/company/banubmt/',
              'color': '#0077B5',
            },
            {
              'name': 'YouTube',
              'icon': 'play_circle_filled',
              'url': 'https://youtube.com/@banubmt?si=w6Qi4NEKYoOmUZmz',
              'color': '#FF0000',
            },
            {
              'name': 'TikTok',
              'icon': 'music_note',
              'url': 'https://www.tiktok.com/@banubmt',
              'color': '#000000',
            },
          ],
        };
      }
      return snapshot.data()!;
    });
  }

  // Update contact settings
  Future<void> updateContactSettings(Map<String, dynamic> settings) async {
    await _firestore
        .collection(_contactSettingsCollection)
        .doc(_contactSettingsDocId)
        .set(settings, SetOptions(merge: true));
  }

}

class EventData {
  final String? id;
  final String type;
  final String title;
  final String date;
  final String time;
  final String location;
  final int participants;

  final String colorHex;


  EventData({
    this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.participants,
    required this.colorHex,
  });


  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'participants': participants,
      'colorHex': colorHex,
    };
  }


  factory EventData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventData(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      participants: data['participants'] ?? 0,
      colorHex: data['colorHex'] ?? '#2196F3',
    );
  }


  Color get color {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  EventData copyWith({
    String? id,
    String? type,
    String? title,
    String? date,
    String? time,
    String? location,
    int? participants,
    String? colorHex,
  }) {
    return EventData(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      participants: participants ?? this.participants,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}

