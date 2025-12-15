import 'dart:html' as html;

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
      final ref = _storage.ref().child('team_members/$memberId/$fileName');
      
      final uploadTask = ref.putBlob(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('❌ Team member photo upload error: $e');
      rethrow;
    }
  }
}

