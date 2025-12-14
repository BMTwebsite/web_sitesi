import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Bir hata oluştu: $e';
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Bir hata oluştu: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is admin (check in Firestore admins collection)
  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null || user.email == null) return false;
    
    try {
      final query = await _firestore
          .collection('admins')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Synchronous version (for quick checks, may not be accurate)
  bool isAdminSync() {
    final user = currentUser;
    if (user == null) return false;
    // For synchronous checks, we can't query Firestore
    // This is a fallback - use isAdmin() for accurate checks
    return true; // Assume true if logged in, verify with isAdmin() when needed
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Yanlış şifre.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu kullanıcı devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem izin verilmemiş.';
      default:
        return 'Giriş yapılırken bir hata oluştu: ${e.message}';
    }
  }
}

