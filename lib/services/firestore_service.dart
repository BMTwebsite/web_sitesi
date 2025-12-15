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
  
  // Firestore bağlantısını test et
  Future<bool> testConnection() async {
    try {
      await _firestore.collection('_test').limit(1).get().timeout(
        const Duration(seconds: 5),
      );
      return true;
    } catch (e) {
      print('❌ Firestore bağlantı testi başarısız: $e');
      return false;
    }
  }
  
  // Belirli bir koleksiyon için okuma iznini test et
  Future<String?> testReadPermission(String collectionName) async {
    try {
      await _firestore.collection(collectionName).limit(1).get().timeout(
        const Duration(seconds: 5),
      );
      return null; // Başarılı
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        return 'Firestore Security Rules hatası: $collectionName koleksiyonu için okuma izni verilmelidir.\n\n'
            'Firebase Console\'da Firestore Database > Rules sekmesine gidin ve şu kuralı ekleyin:\n\n'
            'match /$collectionName/{document=**} {\n'
            '  allow read, write: if true;\n'
            '}\n\n'
            'Sonra Publish butonuna tıklayın!';
      } else if (e.code == 'unavailable') {
        return 'Firestore şu anda kullanılamıyor. İnternet bağlantınızı kontrol edin.';
      } else {
        return 'Firestore hatası (${e.code}): ${e.message}';
      }
    } catch (e) {
      return 'Beklenmeyen hata: $e';
    }
  }
  final String _eventsCollection = 'events';
  final String _pendingAdminsCollection = 'pending_admins';
  final String _adminsCollection = 'admins';
  final String _contactSettingsCollection = 'contact_settings';
  final String _contactSettingsDocId = 'main';
  final String _siteSettingsCollection = 'site_settings';
  final String _siteSettingsDocId = 'main';
  final String _announcementsCollection = 'announcements';
  final String _teamsCollection = 'teams';
  final String _teamMembersCollection = 'team_members';
  final String _sponsorsCollection = 'sponsors';


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

  // Add event and return document reference
  Future<DocumentReference> addEventAndGetRef(EventData event) async {
    final docRef = await _firestore.collection(_eventsCollection).add(event.toMap());
    return docRef;
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
  Future<String> registerPendingAdmin(String firstName, String lastName, String email, String password) async {
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
      
      // Eğer bekleyen kayıt varsa, eski kaydı sil
      if (existingPending.docs.isNotEmpty) {
        print('⚠️ Bu e-posta için bekleyen bir kayıt var, eski kayıt siliniyor...');
        for (var doc in existingPending.docs) {
          await doc.reference.delete();
          print('🗑️ Eski kayıt silindi: ${doc.id}');
        }
        print('✅ Eski kayıtlar temizlendi, yeni kayıt oluşturuluyor...');
      }

      print('🔑 Token oluşturuluyor...');
      // Generate verification token
      final token = DateTime.now().millisecondsSinceEpoch.toString() +
          email.hashCode.toString();

      print('💾 Firestore\'a kayıt yapılıyor...');
      print('📋 Kayıt verisi: firstName=$firstName, lastName=$lastName, email=$email, token=$token');
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
        'firstName': firstName,
        'lastName': lastName,
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
    try {
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
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';

      // Check if admin already exists in admins collection
      final existingAdminQuery = await _firestore
          .collection(_adminsCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // If admin doesn't exist in admins collection, add it
      if (existingAdminQuery.docs.isEmpty) {
        // Use batch to ensure both operations succeed or fail together
        final batch = _firestore.batch();
        
        // Mark as verified in pending_admins
        batch.update(doc.reference, {'verified': true});
        
        // Add to admins collection
        final adminRef = _firestore.collection(_adminsCollection).doc();
        batch.set(adminRef, {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Commit batch transaction
        await batch.commit();
        
        print('✅ Admin başarıyla onaylandı ve admins koleksiyonuna eklendi: $firstName $lastName ($email)');
      } else {
        // Admin already exists, update firstName and lastName if they exist
        final existingDoc = existingAdminQuery.docs.first;
        final updateData = <String, dynamic>{};
        if (firstName.isNotEmpty) updateData['firstName'] = firstName;
        if (lastName.isNotEmpty) updateData['lastName'] = lastName;
        
        if (updateData.isNotEmpty) {
          await existingDoc.reference.update(updateData);
        }
        
        // Mark as verified in pending_admins
        await doc.reference.update({'verified': true});
        print('✅ Admin zaten admins koleksiyonunda, bilgiler güncellendi: $email');
      }

      return {'email': email, 'password': password};
    } catch (e) {
      print('❌ verifyAdmin hatası: $e');
      rethrow;
    }
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
      
      if (query.docs.isEmpty) {
        return 0;
      }
      
      // Batch delete kullan (Firestore'da batch işlemler maksimum 500 doküman)
      int deletedCount = 0;
      const int batchLimit = 500;
      
      for (int i = 0; i < query.docs.length; i += batchLimit) {
        final batch = _firestore.batch();
        final end = (i + batchLimit < query.docs.length) 
            ? i + batchLimit 
            : query.docs.length;
        
        for (int j = i; j < end; j++) {
          batch.delete(query.docs[j].reference);
          deletedCount++;
        }
        
        await batch.commit();
      }
      
      return deletedCount;
    } on FirebaseException catch (e) {
      print('❌ Firebase hatası: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase konsolunda Firestore Security Rules\'ı kontrol edin:\n\n'
            'pending_admins koleksiyonu için silme izni verilmelidir.';
      }
      rethrow;
    } catch (e) {
      print('❌ Tüm bekleyen admin kayıtlarını silme hatası: $e');
      rethrow;
    }
  }

  // Check if admin is verified
  Future<bool> isAdminVerified(String email) async {
    try {
      // Force server fetch to avoid cache issues
      final query = await _firestore
          .collection(_adminsCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get(const GetOptions(source: Source.server));
      
      if (query.docs.isNotEmpty) {
        print('🔍 Admin onay durumu kontrolü: $email -> Onaylı (admins koleksiyonunda)');
        return true;
      }
      
      // If not in admins, check if verified in pending_admins (recovery for partial failures)
      final pendingQuery = await _firestore
          .collection(_pendingAdminsCollection)
          .where('email', isEqualTo: email)
          .where('verified', isEqualTo: true)
          .limit(1)
          .get(const GetOptions(source: Source.server));
      
      if (pendingQuery.docs.isNotEmpty) {
        // Admin is verified but not in admins collection - fix it
        print('⚠️ Admin onaylı ama admins koleksiyonunda yok, düzeltiliyor: $email');
        
        // Add to admins collection
        await _firestore.collection(_adminsCollection).add({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Admin admins koleksiyonuna eklendi: $email');
        return true;
      }
      
      print('🔍 Admin onay durumu kontrolü: $email -> Onaylanmamış');
      return false;
    } catch (e) {
      print('❌ isAdminVerified hatası: $e');
      // On error, return false to be safe
      return false;
    }
  }

  // Get contact settings
  Future<Map<String, dynamic>> getContactSettings() async {
    final doc = await _firestore
        .collection(_contactSettingsCollection)
        .doc(_contactSettingsDocId)
        .get();
    
    if (!doc.exists) {
      // Return empty values - admin will fill these in
      return {
        'email': '',
        'socialMedia': [],
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
        // Return empty values - admin will fill these in
        return {
          'email': '',
          'socialMedia': [],
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

  // Get site settings (site name, description, contact info, address, phone)
  Future<Map<String, dynamic>> getSiteSettings() async {
    final doc = await _firestore
        .collection(_siteSettingsCollection)
        .doc(_siteSettingsDocId)
        .get();
    
    if (!doc.exists) {
      // Return empty values if document doesn't exist
      return {
        'siteName': '',
        'siteDescription': '',
        'email': '',
        'phone': '',
        'address': '',
        'copyright': '',
      };
    }
    
    return doc.data()!;
  }

  // Stream site settings
  Stream<Map<String, dynamic>> getSiteSettingsStream() {
    return _firestore
        .collection(_siteSettingsCollection)
        .doc(_siteSettingsDocId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {
          'siteName': '',
          'siteDescription': '',
          'email': '',
          'phone': '',
          'address': '',
          'copyright': '',
        };
      }
      return snapshot.data()!;
    });
  }

  // Update site settings
  Future<void> updateSiteSettings(Map<String, dynamic> settings) async {
    await _firestore
        .collection(_siteSettingsCollection)
        .doc(_siteSettingsDocId)
        .set(settings, SetOptions(merge: true));
  }

  // Announcements
  Stream<List<AnnouncementData>> getAnnouncements() {
    return _firestore
        .collection(_announcementsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
      print('❌ getAnnouncements hatası: $error');
      if (error is FirebaseException) {
        if (error.code == 'failed-precondition') {
          throw 'Firestore index hatası. Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.';
        } else if (error.code == 'permission-denied') {
          throw 'Firestore izin hatası. Duyurular koleksiyonu için okuma izni verilmelidir.';
        } else if (error.code == 'unavailable') {
          throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
        }
      }
      throw 'Duyurular yüklenirken bir hata oluştu: $error';
    })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnnouncementData.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<AnnouncementData>> getAnnouncementsByType(String type) {
    return _firestore
        .collection(_announcementsCollection)
        .where('type', isEqualTo: type)
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
      print('❌ getAnnouncementsByType hatası: $error');
      if (error is FirebaseException) {
        if (error.code == 'failed-precondition') {
          throw 'Firestore index hatası. Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.';
        } else if (error.code == 'permission-denied') {
          throw 'Firestore izin hatası. Duyurular koleksiyonu için okuma izni verilmelidir.';
        } else if (error.code == 'unavailable') {
          throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
        }
      }
      throw 'Duyurular yüklenirken bir hata oluştu: $error';
    })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnnouncementData.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addAnnouncement(AnnouncementData announcement) async {
    await _firestore.collection(_announcementsCollection).add(announcement.toMap());
  }

  Future<DocumentReference> addAnnouncementAndGetRef(AnnouncementData announcement) async {
    return await _firestore.collection(_announcementsCollection).add(announcement.toMap());
  }

  Future<void> updateAnnouncement(String announcementId, AnnouncementData announcement) async {
    await _firestore
        .collection(_announcementsCollection)
        .doc(announcementId)
        .update(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    await _firestore.collection(_announcementsCollection).doc(announcementId).delete();
  }

  // Teams
  Stream<List<TeamData>> getTeams() {
    return _firestore
        .collection(_teamsCollection)
        .orderBy('name', descending: false)
        .snapshots()
        .handleError((error) {
      print('❌ getTeams hatası: $error');
      if (error is FirebaseException) {
        if (error.code == 'failed-precondition') {
          throw 'Firestore index hatası. Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.';
        } else if (error.code == 'permission-denied') {
          throw 'Firestore izin hatası. Ekipler koleksiyonu için okuma izni verilmelidir.';
        } else if (error.code == 'unavailable') {
          throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
        }
      }
      throw 'Ekipler yüklenirken bir hata oluştu: $error';
    })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TeamData.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addTeam(TeamData team) async {
    try {
      await _firestore.collection(_teamsCollection).add(team.toMap());
    } on FirebaseException catch (e) {
      print('❌ addTeam FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'teams koleksiyonu için yazma izni verilmelidir.\n'
            'Örnek rule:\n'
            'match /teams/{document=**} {\n'
            '  allow write: if request.auth != null;\n'
            '}';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip eklenirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ addTeam hatası: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw 'Firestore izin hatası. Lütfen Firebase konsolunda gerekli izinlerin ayarlandığından emin olun.';
      }
      rethrow;
    }
  }

  Future<DocumentReference> addTeamAndGetRef(TeamData team) async {
    try {
      return await _firestore.collection(_teamsCollection).add(team.toMap());
    } on FirebaseException catch (e) {
      print('❌ addTeamAndGetRef FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'teams koleksiyonu için yazma izni verilmelidir.\n'
            'Örnek rule:\n'
            'match /teams/{document=**} {\n'
            '  allow write: if request.auth != null;\n'
            '}';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip eklenirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ addTeamAndGetRef hatası: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw 'Firestore izin hatası. Lütfen Firebase konsolunda gerekli izinlerin ayarlandığından emin olun.';
      }
      rethrow;
    }
  }

  Future<void> updateTeam(String teamId, TeamData team) async {
    try {
      await _firestore
          .collection(_teamsCollection)
          .doc(teamId)
          .update(team.toMap());
    } on FirebaseException catch (e) {
      print('❌ updateTeam FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'teams koleksiyonu için yazma izni verilmelidir.';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip güncellenirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ updateTeam hatası: $e');
      rethrow;
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      // Delete all team members first
      final membersQuery = await _firestore
          .collection(_teamMembersCollection)
          .where('teamId', isEqualTo: teamId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in membersQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // Delete team
      await _firestore.collection(_teamsCollection).doc(teamId).delete();
    } on FirebaseException catch (e) {
      print('❌ deleteTeam FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'teams ve team_members koleksiyonları için silme izni verilmelidir.';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip silinirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ deleteTeam hatası: $e');
      rethrow;
    }
  }

  // Team Members
  Stream<List<TeamMemberData>> getTeamMembers(String teamId) {
    return _firestore
        .collection(_teamMembersCollection)
        .where('teamId', isEqualTo: teamId)
        .orderBy('name', descending: false)
        .snapshots()
        .handleError((error) {
      print('❌ getTeamMembers hatası: $error');
      if (error is FirebaseException) {
        if (error.code == 'failed-precondition') {
          throw 'Firestore index hatası. Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.';
        } else if (error.code == 'permission-denied') {
          throw 'Firestore izin hatası. Ekip üyeleri koleksiyonu için okuma izni verilmelidir.';
        } else if (error.code == 'unavailable') {
          throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
        }
      }
      throw 'Ekip üyeleri yüklenirken bir hata oluştu: $error';
    })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TeamMemberData.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<TeamMemberData>> getAllTeamMembers() {
    return _firestore
        .collection(_teamMembersCollection)
        .orderBy('name', descending: false)
        .snapshots()
        .handleError((error) {
      print('❌ getAllTeamMembers hatası: $error');
      if (error is FirebaseException) {
        if (error.code == 'failed-precondition') {
          throw 'Firestore index hatası. Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.';
        } else if (error.code == 'permission-denied') {
          throw 'Firestore izin hatası. Ekip üyeleri koleksiyonu için okuma izni verilmelidir.';
        } else if (error.code == 'unavailable') {
          throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
        }
      }
      throw 'Ekip üyeleri yüklenirken bir hata oluştu: $error';
    })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TeamMemberData.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addTeamMember(TeamMemberData member) async {
    try {
      await _firestore.collection(_teamMembersCollection).add(member.toMap());
    } on FirebaseException catch (e) {
      print('❌ addTeamMember FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'team_members koleksiyonu için yazma izni verilmelidir.\n'
            'Örnek rule:\n'
            'match /team_members/{document=**} {\n'
            '  allow write: if request.auth != null;\n'
            '}';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip üyesi eklenirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ addTeamMember hatası: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw 'Firestore izin hatası. Lütfen Firebase konsolunda gerekli izinlerin ayarlandığından emin olun.';
      }
      rethrow;
    }
  }

  Future<DocumentReference> addTeamMemberAndGetRef(TeamMemberData member) async {
    try {
      return await _firestore.collection(_teamMembersCollection).add(member.toMap());
    } on FirebaseException catch (e) {
      print('❌ addTeamMemberAndGetRef FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'team_members koleksiyonu için yazma izni verilmelidir.\n'
            'Örnek rule:\n'
            'match /team_members/{document=**} {\n'
            '  allow write: if request.auth != null;\n'
            '}';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip üyesi eklenirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ addTeamMemberAndGetRef hatası: $e');
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw 'Firestore izin hatası. Lütfen Firebase konsolunda gerekli izinlerin ayarlandığından emin olun.';
      }
      rethrow;
    }
  }

  Future<void> updateTeamMember(String memberId, TeamMemberData member) async {
    try {
      await _firestore
          .collection(_teamMembersCollection)
          .doc(memberId)
          .update(member.toMap());
    } on FirebaseException catch (e) {
      print('❌ updateTeamMember FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'team_members koleksiyonu için yazma izni verilmelidir.';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip üyesi güncellenirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ updateTeamMember hatası: $e');
      rethrow;
    }
  }

  Future<void> deleteTeamMember(String memberId) async {
    try {
      await _firestore.collection(_teamMembersCollection).doc(memberId).delete();
    } on FirebaseException catch (e) {
      print('❌ deleteTeamMember FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw 'Firestore izin hatası. Firebase Console\'da Firestore Security Rules\'ı kontrol edin:\n\n'
            'team_members koleksiyonu için silme izni verilmelidir.';
      } else if (e.code == 'unavailable') {
        throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
      } else {
        throw 'Ekip üyesi silinirken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      print('❌ deleteTeamMember hatası: $e');
      rethrow;
    }
  }

  // Sponsors
  Stream<List<SponsorData>> getSponsors() {
    return _firestore
        .collection(_sponsorsCollection)
        .orderBy('name', descending: false)
        .snapshots()
        .handleError((error) {
      print('❌ getSponsors hatası: $error');
      if (error is FirebaseException) {
        if (error.code == 'failed-precondition') {
          throw 'Firestore index hatası. Firebase Console\'da gerekli index\'i oluşturmanız gerekiyor.';
        } else if (error.code == 'permission-denied') {
          throw 'Firestore izin hatası. Sponsorlar koleksiyonu için okuma izni verilmelidir.';
        } else if (error.code == 'unavailable') {
          throw 'Firestore şu anda kullanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
        }
      }
      throw 'Sponsorlar yüklenirken bir hata oluştu: $error';
    })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SponsorData.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addSponsor(SponsorData sponsor) async {
    await _firestore.collection(_sponsorsCollection).add(sponsor.toMap());
  }

  Future<DocumentReference> addSponsorAndGetRef(SponsorData sponsor) async {
    return await _firestore.collection(_sponsorsCollection).add(sponsor.toMap());
  }

  Future<void> updateSponsor(String sponsorId, SponsorData sponsor) async {
    await _firestore
        .collection(_sponsorsCollection)
        .doc(sponsorId)
        .update(sponsor.toMap());
  }

  Future<void> deleteSponsor(String sponsorId) async {
    await _firestore.collection(_sponsorsCollection).doc(sponsorId).delete();
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
  final List<String> images;

  EventData({
    this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.participants,
    required this.colorHex,
    this.images = const [],
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
      'images': images,
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
      images: List<String>.from(data['images'] ?? []),
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
    List<String>? images,
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
      images: images ?? this.images,
    );
  }
}

class AnnouncementData {
  final String? id;
  final String type; // 'bölüm', 'etkinlik', 'topluluk'
  final String eventName; // Etkinlik adı
  final String posterUrl; // Afiş URL'i
  final String date; // Tarih
  final String address; // Adres
  final String? description; // Açıklama (opsiyonel)
  final String colorHex; // Renk hex kodu

  AnnouncementData({
    this.id,
    required this.type,
    required this.eventName,
    required this.posterUrl,
    required this.date,
    required this.address,
    this.description,
    this.colorHex = '#2196F3',
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'eventName': eventName,
      'posterUrl': posterUrl,
      'date': date,
      'address': address,
      'description': description ?? '',
      'colorHex': colorHex,
    };
  }

  factory AnnouncementData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementData(
      id: doc.id,
      type: data['type'] ?? '',
      eventName: data['eventName'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      date: data['date'] ?? '',
      address: data['address'] ?? '',
      description: data['description'],
      colorHex: data['colorHex'] ?? '#2196F3',
    );
  }

  Color get color {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  AnnouncementData copyWith({
    String? id,
    String? type,
    String? eventName,
    String? posterUrl,
    String? date,
    String? address,
    String? description,
    String? colorHex,
  }) {
    return AnnouncementData(
      id: id ?? this.id,
      type: type ?? this.type,
      eventName: eventName ?? this.eventName,
      posterUrl: posterUrl ?? this.posterUrl,
      date: date ?? this.date,
      address: address ?? this.address,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}

class TeamData {
  final String? id;
  final String name;
  final String? description;

  TeamData({
    this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description ?? '',
    };
  }

  factory TeamData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamData(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
    );
  }

  TeamData copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return TeamData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

class TeamMemberData {
  final String? id;
  final String teamId;
  final String name;
  final String department; // Bölüm
  final String? className; // Sınıf
  final String title; // Ünvan
  final String? photoUrl; // Fotoğraf URL'i

  TeamMemberData({
    this.id,
    required this.teamId,
    required this.name,
    required this.department,
    this.className,
    required this.title,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'name': name,
      'department': department,
      'className': className ?? '',
      'title': title,
      'photoUrl': photoUrl ?? '',
    };
  }

  factory TeamMemberData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamMemberData(
      id: doc.id,
      teamId: data['teamId'] ?? '',
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      className: data['className'],
      title: data['title'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  TeamMemberData copyWith({
    String? id,
    String? teamId,
    String? name,
    String? department,
    String? className,
    String? title,
    String? photoUrl,
  }) {
    return TeamMemberData(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      department: department ?? this.department,
      className: className ?? this.className,
      title: title ?? this.title,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class SponsorData {
  final String? id;
  final String name;
  final String? description;
  final String logoUrl;
  final String? websiteUrl;
  final String tier; // 'platinum', 'gold', 'silver', 'bronze'
  final int? order; // Sıralama için

  SponsorData({
    this.id,
    required this.name,
    this.description,
    required this.logoUrl,
    this.websiteUrl,
    this.tier = 'bronze',
    this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description ?? '',
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl ?? '',
      'tier': tier,
      'order': order ?? 0,
    };
  }

  factory SponsorData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SponsorData(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      logoUrl: data['logoUrl'] ?? '',
      websiteUrl: data['websiteUrl'],
      tier: data['tier'] ?? 'bronze',
      order: data['order'],
    );
  }

  Color get tierColor {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF2196F3);
    }
  }

  SponsorData copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? websiteUrl,
    String? tier,
    int? order,
  }) {
    return SponsorData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      tier: tier ?? this.tier,
      order: order ?? this.order,
    );
  }
}

