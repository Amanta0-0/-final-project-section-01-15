import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_firebase/models/match_model.dart'; // contains UserModel in your project

/// Auth Provider for authentication state management
class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuthListener();
  }

  /// Initialize auth state listener (no-op placeholder)
  void _initAuthListener() {
    // Add real auth listener integration here if needed.
  }

  /// Sign up a new user (mock implementation)
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!email.contains('@') || !email.contains('.')) {
        _error = 'Please enter a valid email address';
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        return false;
      }

      _currentUser = UserModel(
        uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: '$firstName $lastName',
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        photoUrl: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      _error = 'Sign up failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in existing user (mock implementation)
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!email.contains('@') || !email.contains('.')) {
        _error = 'Please enter a valid email address';
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        return false;
      }

      final emailParts = email.split('@');
      final name = emailParts[0];
      final first = name.contains('.') ? name.split('.').first : name;
      final last = name.contains('.') ? name.split('.').last : '';

      _currentUser = UserModel(
        uid: 'mock_user_${email.hashCode}',
        email: email,
        displayName: '$first ${last.isNotEmpty ? last : ''}'.trim(),
        firstName: first,
        lastName: last.isNotEmpty ? last : null,
        phoneNumber: '123-456-7890',
        photoUrl: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      _error = 'Sign in failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = null;
    } catch (e) {
      _error = 'Sign out failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = user;
      return true;
    } catch (e) {
      _error = 'Update profile failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email (mock)
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Implement real reset logic when integrating an auth service.
      return true;
    } catch (e) {
      _error = 'Failed to send password reset email: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
