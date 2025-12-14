import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

// Re-export EventData for convenience
export '../services/firestore_service.dart' show EventData;

class FirestoreProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  FirestoreService get firestoreService => _firestoreService;

  // Events
  Stream<List<EventData>> getEvents() {
    return _firestoreService.getEvents();
  }

  Future<void> addEvent(EventData event) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addEvent(event);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEvent(String eventId, EventData event) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateEvent(eventId, event);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteEvent(eventId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Admin registration
  Future<String> registerPendingAdmin(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _error = null;
      final token = await _firestoreService.registerPendingAdmin(
        firstName,
        lastName,
        email,
        password,
      );
      _setLoading(false);
      notifyListeners();
      return token;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Verify admin
  Future<Map<String, String>> verifyAdmin(String token) async {
    try {
      _setLoading(true);
      _error = null;
      final result = await _firestoreService.verifyAdmin(token);
      _setLoading(false);
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Reject admin
  Future<void> rejectAdmin(String token) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.rejectAdmin(token);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Delete all pending admins
  Future<int> deleteAllPendingAdmins() async {
    try {
      _setLoading(true);
      _error = null;
      final count = await _firestoreService.deleteAllPendingAdmins();
      _setLoading(false);
      notifyListeners();
      return count;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Check if admin is verified
  Future<bool> isAdminVerified(String email) async {
    try {
      return await _firestoreService.isAdminVerified(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Contact settings
  Stream<Map<String, dynamic>> getContactSettingsStream() {
    return _firestoreService.getContactSettingsStream();
  }

  Future<Map<String, dynamic>> getContactSettings() async {
    try {
      return await _firestoreService.getContactSettings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateContactSettings(Map<String, dynamic> settings) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateContactSettings(settings);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Site settings
  Stream<Map<String, dynamic>> getSiteSettingsStream() {
    return _firestoreService.getSiteSettingsStream();
  }

  Future<Map<String, dynamic>> getSiteSettings() async {
    try {
      return await _firestoreService.getSiteSettings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSiteSettings(Map<String, dynamic> settings) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateSiteSettings(settings);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

