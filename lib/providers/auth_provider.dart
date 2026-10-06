import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _user;
  bool _isLoading = false;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _user = _authService.currentUser;
    _authService.userStream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.isStudent ?? false;
  bool get isLoading => _isLoading || _isEmailLoading || _isGoogleLoading;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    _setEmailLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.signIn(email: email, password: password);
      _setEmailLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setEmailLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setGoogleLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.signInWithGoogle();
      _setGoogleLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setGoogleLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String grade,
    required String school,
    required String role,
  }) async {
    _setEmailLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        grade: grade,
        school: school,
        role: role,
      );
      _setEmailLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setEmailLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String grade,
    required String school,
    String? profilePicUrl,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.updateProfile(
        name: name,
        phone: phone,
        grade: grade,
        school: school,
        profilePicUrl: profilePicUrl,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void switchRole(String role) {
    _authService.switchRole(role);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setEmailLoading(bool value) {
    _isEmailLoading = value;
    notifyListeners();
  }

  void _setGoogleLoading(bool value) {
    _isGoogleLoading = value;
    notifyListeners();
  }
}
