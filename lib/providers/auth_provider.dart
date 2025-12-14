import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _checkAdminStatus();
      } else {
        _isAdmin = false;
      }
      notifyListeners();
    });

    // Initialize current user
    _user = _authService.currentUser;
    if (_user != null) {
      _checkAdminStatus();
    }
  }

  Future<void> _checkAdminStatus() async {
    try {
      _isAdmin = await _authService.isAdmin();
      notifyListeners();
    } catch (e) {
      _isAdmin = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _authService.signInWithEmailAndPassword(email, password);
      
      // User will be updated via authStateChanges stream
      await _checkAdminStatus();
      
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _error = null;
      
      await _authService.signOut();
      
      _user = null;
      _isAdmin = false;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> checkAdminStatus() async {
    try {
      _isAdmin = await _authService.isAdmin();
      notifyListeners();
      return _isAdmin;
    } catch (e) {
      _isAdmin = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      
      final credential = await _authService.createUserWithEmailAndPassword(email, password);
      _user = credential.user;
      
      // User will be updated via authStateChanges stream
      await _checkAdminStatus();
      
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

