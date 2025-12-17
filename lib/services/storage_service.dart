import 'dart:async';
import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a single image file and return its download URL
  Future<String> uploadImage(html.File file, String eventId, int imageIndex) async {
    try {
      final fileName = 'event_${eventId}_image_$imageIndex.${file.name.split('.').last}';
      final ref = _storage.ref().child('events/$eventId/$fileName');
      
      final uploadTask = ref.putBlob(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('❌ Image upload error: $e');
      rethrow;
    }
  }

  /// Upload multiple images and return their download URLs
  Future<List<String>> uploadImages(List<html.File> files, String eventId) async {
    try {
      final List<String> urls = [];
      
      for (int i = 0; i < files.length; i++) {
        final url = await uploadImage(files[i], eventId, i);
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('❌ Multiple image upload error: $e');
      rethrow;
    }
  }

  /// Upload announcement poster and return its download URL
  Future<String> uploadAnnouncementPoster(html.File file, String announcementId) async {
    try {
      final fileName = 'announcement_${announcementId}_poster.${file.name.split('.').last}';
      final storagePath = 'announcements/$announcementId/$fileName';
      print('📤 Storage path: $storagePath');
      print('📤 File name: ${file.name}, size: ${file.size} bytes');
      
      final ref = _storage.ref().child(storagePath);
      
      print('📤 Upload başlatılıyor...');
      print('📤 Storage bucket: ${_storage.app.options.storageBucket}');
      print('📤 Storage ref full path: ${ref.fullPath}');
      
      final uploadTask = ref.putBlob(file);
      
      // Check initial state
      print('📤 Upload task oluşturuldu. Initial state: ${uploadTask.snapshot.state}');
      
      // Upload progress listener with error handling
      StreamSubscription? progressSubscription;
      try {
        progressSubscription = uploadTask.snapshotEvents.listen(
          (taskSnapshot) {
            final progress = taskSnapshot.totalBytes > 0 
                ? (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) * 100
                : 0.0;
            print('📊 Upload progress: ${progress.toStringAsFixed(1)}% (${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes} bytes)');
            print('📊 Upload state: ${taskSnapshot.state}');
            
            // Check for errors in state
            if (taskSnapshot.state == TaskState.error) {
              print('❌ Upload task error state detected!');
            }
          },
          onError: (error) {
            print('❌ Upload progress listener error: $error');
          },
        );
      } catch (e) {
        print('⚠️ Progress listener oluşturulamadı: $e');
      }
      
      // Wait for upload with timeout and better error handling
      TaskSnapshot snapshot;
      try {
        snapshot = await uploadTask.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('❌ Upload timeout! 30 saniye içinde tamamlanamadı.');
            print('❌ Son durum: ${uploadTask.snapshot.state}');
            print('❌ Bytes transferred: ${uploadTask.snapshot.bytesTransferred} / ${uploadTask.snapshot.totalBytes}');
            progressSubscription?.cancel();
            throw Exception('Afiş yükleme işlemi zaman aşımına uğradı. Firebase Storage Rules\'ı kontrol edin ve internet bağlantınızı kontrol edin.');
          },
        );
        progressSubscription?.cancel();
      } catch (timeoutError) {
        progressSubscription?.cancel();
        print('❌ Upload timeout hatası: $timeoutError');
        rethrow;
      }
      
      print('✅ Upload tamamlandı. Snapshot state: ${snapshot.state}');
      print('✅ Bytes transferred: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}');
      
      print('📥 Download URL alınıyor...');
      String downloadUrl;
      try {
        downloadUrl = await snapshot.ref.getDownloadURL().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('❌ Download URL alma timeout!');
            throw Exception('Afiş URL\'si alınamadı. Lütfen tekrar deneyin.');
          },
        );
      } catch (urlError) {
        print('❌ Download URL alma hatası: $urlError');
        rethrow;
      }
      
      print('✅ Download URL alındı: $downloadUrl');
      
      if (downloadUrl.isEmpty) {
        throw Exception('Download URL boş döndü');
      }
      
      return downloadUrl;
    } catch (e) {
      print('❌ Announcement poster upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      
      if (e is FirebaseException) {
        print('❌ Firebase error code: ${e.code}');
        print('❌ Firebase error message: ${e.message}');
        
        // Daha açıklayıcı hata mesajları
        String userFriendlyMessage;
        switch (e.code) {
          case 'unauthorized':
          case 'permission-denied':
            userFriendlyMessage = 'Firebase Storage izin hatası. Firebase Console\'da Storage Rules\'ı kontrol edin. announcements klasörü için yazma izni verilmelidir.';
            break;
          case 'unauthenticated':
            userFriendlyMessage = 'Kimlik doğrulama hatası. Lütfen tekrar giriş yapın.';
            break;
          case 'object-not-found':
            userFriendlyMessage = 'Dosya bulunamadı.';
            break;
          case 'quota-exceeded':
            userFriendlyMessage = 'Storage kotası aşıldı.';
            break;
          default:
            userFriendlyMessage = 'Firebase Storage hatası: ${e.message ?? e.code}';
        }
        throw Exception(userFriendlyMessage);
      }
      
      rethrow;
    }
  }

  /// Delete an image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('❌ Image delete error: $e');
      // Don't rethrow - deletion errors shouldn't block the operation
    }
  }

  /// Delete multiple images from storage
  Future<void> deleteImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }

  /// Upload team member photo and return its download URL
  Future<String> uploadTeamMemberPhoto(html.File file, String memberId) async {
    try {
      final fileName = 'member_${memberId}_photo.${file.name.split('.').last}';
      final storagePath = 'team_members/$memberId/$fileName';
      print('📤 Storage path: $storagePath');
      print('📤 File name: ${file.name}, size: ${file.size} bytes');
      
      final ref = _storage.ref().child(storagePath);
      
      print('📤 Upload başlatılıyor...');
      print('📤 Storage bucket: ${_storage.app.options.storageBucket}');
      print('📤 Storage ref full path: ${ref.fullPath}');
      
      final uploadTask = ref.putBlob(file);
      
      // Check initial state
      print('📤 Upload task oluşturuldu. Initial state: ${uploadTask.snapshot.state}');
      
      // Upload progress listener with error handling
      StreamSubscription? progressSubscription;
      try {
        progressSubscription = uploadTask.snapshotEvents.listen(
          (taskSnapshot) {
            final progress = taskSnapshot.totalBytes > 0 
                ? (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) * 100
                : 0.0;
            print('📊 Upload progress: ${progress.toStringAsFixed(1)}% (${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes} bytes)');
            print('📊 Upload state: ${taskSnapshot.state}');
            
            // Check for errors in state
            if (taskSnapshot.state == TaskState.error) {
              print('❌ Upload task error state detected!');
            }
          },
          onError: (error) {
            print('❌ Upload progress listener error: $error');
          },
        );
      } catch (e) {
        print('⚠️ Progress listener oluşturulamadı: $e');
      }
      
      // Wait for upload with timeout and better error handling
      TaskSnapshot snapshot;
      try {
        snapshot = await uploadTask.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('❌ Upload timeout! 30 saniye içinde tamamlanamadı.');
            print('❌ Son durum: ${uploadTask.snapshot.state}');
            print('❌ Bytes transferred: ${uploadTask.snapshot.bytesTransferred} / ${uploadTask.snapshot.totalBytes}');
            progressSubscription?.cancel();
            throw Exception('Fotoğraf yükleme işlemi zaman aşımına uğradı. Firebase Storage Rules\'ı kontrol edin ve internet bağlantınızı kontrol edin.');
          },
        );
        progressSubscription?.cancel();
      } catch (timeoutError) {
        progressSubscription?.cancel();
        print('❌ Upload timeout hatası: $timeoutError');
        rethrow;
      }
      
      print('✅ Upload tamamlandı. Snapshot state: ${snapshot.state}');
      print('✅ Bytes transferred: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}');
      
      print('📥 Download URL alınıyor...');
      String downloadUrl;
      try {
        downloadUrl = await snapshot.ref.getDownloadURL().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('❌ Download URL alma timeout!');
            throw Exception('Fotoğraf URL\'si alınamadı. Lütfen tekrar deneyin.');
          },
        );
      } catch (urlError) {
        print('❌ Download URL alma hatası: $urlError');
        rethrow;
      }
      
      print('✅ Download URL alındı: $downloadUrl');
      
      if (downloadUrl.isEmpty) {
        throw Exception('Download URL boş döndü');
      }
      
      return downloadUrl;
    } catch (e) {
      print('❌ Team member photo upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      
      if (e is FirebaseException) {
        print('❌ Firebase error code: ${e.code}');
        print('❌ Firebase error message: ${e.message}');
        
        // Daha açıklayıcı hata mesajları
        String userFriendlyMessage;
        switch (e.code) {
          case 'unauthorized':
          case 'permission-denied':
            userFriendlyMessage = 'Firebase Storage izin hatası. Firebase Console\'da Storage Rules\'ı kontrol edin. team_members klasörü için yazma izni verilmelidir.';
            break;
          case 'unauthenticated':
            userFriendlyMessage = 'Kimlik doğrulama hatası. Lütfen tekrar giriş yapın.';
            break;
          case 'object-not-found':
            userFriendlyMessage = 'Dosya bulunamadı.';
            break;
          case 'quota-exceeded':
            userFriendlyMessage = 'Storage kotası aşıldı.';
            break;
          default:
            userFriendlyMessage = 'Firebase Storage hatası: ${e.message ?? e.code}';
        }
        throw Exception(userFriendlyMessage);
      }
      
      rethrow;
    }
  }

  /// Upload sponsor logo and return its download URL
  Future<String> uploadSponsorLogo(html.File file, String sponsorId) async {
    try {
      final fileName = 'sponsor_${sponsorId}_logo.${file.name.split('.').last}';
      final storagePath = 'sponsors/$sponsorId/$fileName';
      print('📤 Storage path: $storagePath');
      print('📤 File name: ${file.name}, size: ${file.size} bytes');
      
      final ref = _storage.ref().child(storagePath);
      
      print('📤 Upload başlatılıyor...');
      
      final uploadTask = ref.putBlob(file);
      
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Upload timeout! 30 saniye içinde tamamlanamadı.');
          throw TimeoutException('Upload timeout');
        },
      );
      
      print('✅ Upload tamamlandı. Snapshot state: ${snapshot.state}');
      
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Sponsor logo uploaded successfully: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      print('❌ Sponsor logo upload error: $e');
      rethrow;
    }
  }

  /// Upload community logo and return its download URL
  Future<String> uploadCommunityLogo(html.File file) async {
    try {
      final fileName = 'community_logo.${file.name.split('.').last}';
      final storagePath = 'site/community_logo/$fileName';
      print('📤 Storage path: $storagePath');
      print('📤 File name: ${file.name}, size: ${file.size} bytes');
      
      final ref = _storage.ref().child(storagePath);
      
      print('📤 Upload başlatılıyor...');
      print('📤 Storage bucket: ${_storage.app.options.storageBucket}');
      print('📤 Storage ref full path: ${ref.fullPath}');
      
      final uploadTask = ref.putBlob(file);
      
      print('📤 Upload task oluşturuldu. Initial state: ${uploadTask.snapshot.state}');
      
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Upload timeout! 30 saniye içinde tamamlanamadı.');
          throw Exception('Logo yükleme işlemi zaman aşımına uğradı. Firebase Storage Rules\'ı kontrol edin ve internet bağlantınızı kontrol edin.');
        },
      );
      
      print('✅ Upload tamamlandı. Snapshot state: ${snapshot.state}');
      
      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('❌ Download URL alma timeout!');
          throw Exception('Logo URL\'si alınamadı. Lütfen tekrar deneyin.');
        },
      );
      
      print('✅ Download URL alındı: $downloadUrl');
      
      if (downloadUrl.isEmpty) {
        throw Exception('Download URL boş döndü');
      }
      
      return downloadUrl;
    } catch (e) {
      print('❌ Community logo upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      if (e is FirebaseException) {
        print('❌ Firebase error code: ${e.code}');
        print('❌ Firebase error message: ${e.message}');
        
        String userFriendlyMessage;
        switch (e.code) {
          case 'unauthorized':
          case 'permission-denied':
            userFriendlyMessage = 'Firebase Storage izin hatası. Firebase Console\'da Storage Rules\'ı kontrol edin. site klasörü için yazma izni verilmelidir.';
            break;
          case 'unauthenticated':
            userFriendlyMessage = 'Kimlik doğrulama hatası. Lütfen tekrar giriş yapın.';
            break;
          case 'object-not-found':
            userFriendlyMessage = 'Dosya bulunamadı.';
            break;
          case 'quota-exceeded':
            userFriendlyMessage = 'Storage kotası aşıldı.';
            break;
          default:
            userFriendlyMessage = 'Firebase Storage hatası: ${e.message ?? e.code}';
        }
        throw Exception(userFriendlyMessage);
      }
      
      rethrow;
    }
  }

  /// Upload home section image and return its download URL
  Future<String> uploadHomeSectionImage(html.File file, String sectionId) async {
    try {
      final fileName = 'section_${sectionId}_image.${file.name.split('.').last}';
      final storagePath = 'home_sections/$sectionId/$fileName';
      print('📤 Storage path: $storagePath');
      print('📤 File name: ${file.name}, size: ${file.size} bytes');
      
      final ref = _storage.ref().child(storagePath);
      
      print('📤 Upload başlatılıyor...');
      print('📤 Storage bucket: ${_storage.app.options.storageBucket}');
      print('📤 Storage ref full path: ${ref.fullPath}');
      
      final uploadTask = ref.putBlob(file);
      
      print('📤 Upload task oluşturuldu. Initial state: ${uploadTask.snapshot.state}');
      
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Upload timeout! 30 saniye içinde tamamlanamadı.');
          throw Exception('Resim yükleme işlemi zaman aşımına uğradı. Firebase Storage Rules\'ı kontrol edin ve internet bağlantınızı kontrol edin.');
        },
      );
      
      print('✅ Upload tamamlandı. Snapshot state: ${snapshot.state}');
      
      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('❌ Download URL alma timeout!');
          throw Exception('Resim URL\'si alınamadı. Lütfen tekrar deneyin.');
        },
      );
      
      print('✅ Download URL alındı: $downloadUrl');
      
      if (downloadUrl.isEmpty) {
        throw Exception('Download URL boş döndü');
      }
      
      return downloadUrl;
    } catch (e) {
      print('❌ Home section image upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      if (e is FirebaseException) {
        print('❌ Firebase error code: ${e.code}');
        print('❌ Firebase error message: ${e.message}');
        
        String userFriendlyMessage;
        switch (e.code) {
          case 'unauthorized':
          case 'permission-denied':
            userFriendlyMessage = 'Firebase Storage izin hatası. Firebase Console\'da Storage Rules\'ı kontrol edin. home_sections klasörü için yazma izni verilmelidir.';
            break;
          case 'unauthenticated':
            userFriendlyMessage = 'Kimlik doğrulama hatası. Lütfen tekrar giriş yapın.';
            break;
          case 'object-not-found':
            userFriendlyMessage = 'Dosya bulunamadı.';
            break;
          case 'quota-exceeded':
            userFriendlyMessage = 'Storage kotası aşıldı.';
            break;
          default:
            userFriendlyMessage = 'Firebase Storage hatası: ${e.message ?? e.code}';
        }
        throw Exception(userFriendlyMessage);
      }
      
      rethrow;
    }
  }
}

