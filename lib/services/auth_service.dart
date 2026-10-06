import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

import 'web_helper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  final StreamController<UserModel?> _userStreamController = StreamController<UserModel?>.broadcast();

  static final Map<String, String> _profilePicCache = {};

  // Pre-registered / Allowed emails set
  final Set<String> _preRegisteredEmails = {
    'student@akilamaths.lk',
    'student.google@akilamaths.lk',
    'akila@admin.com',
    'admin@akilamaths.lk',
    'kasun375@gmail.com',
  };

  // Currently registered emails set (to enforce 1 email can only be registered 1 time)
  final Set<String> _registeredEmails = {
    'student@akilamaths.lk',
    'student.google@akilamaths.lk',
    'akila@admin.com',
    'admin@akilamaths.lk',
  };

  Stream<UserModel?> get userStream => _userStreamController.stream;
  UserModel? get currentUser => _currentUser;

  AuthService() {
    _restoreSavedSession();
    _listenToAuthState();
  }

  /// Pre-registers a new student email (Admin Feature)
  Future<void> preRegisterEmail(String email) async {
    final lower = email.trim().toLowerCase();
    if (lower.isEmpty) return;
    _preRegisteredEmails.add(lower);
    try {
      await _firestore.collection('pre_registered_emails').doc(lower).set({
        'email': lower,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore preRegisterEmail error: $e");
    }
  }

  /// Checks if an email is already registered in the system (1 email only can add for 1 time)
  Future<bool> _isEmailAlreadyRegistered(String email) async {
    final lower = email.trim().toLowerCase();
    if (lower.isEmpty) return false;

    if (_registeredEmails.contains(lower)) return true;

    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: lower)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        _registeredEmails.add(lower);
        return true;
      }
    } catch (e) {
      debugPrint("Firestore _isEmailAlreadyRegistered query error: $e");
    }
    return false;
  }

  /// Restores session & profile picture from local storage on browser page refresh
  void _restoreSavedSession() {
    if (kIsWeb) {
      try {
        final savedJson = WebStorage.localStorage['akila_lms_user'];
        if (savedJson != null && savedJson.isNotEmpty) {
          final Map<String, dynamic> map = jsonDecode(savedJson);
          final uid = map['uid'] ?? 'user_restored';
          final savedPic = WebStorage.localStorage['profile_pic_$uid'] ?? map['profilePicUrl'] ?? '';
          if (savedPic.isNotEmpty) {
            map['profilePicUrl'] = savedPic;
            _profilePicCache[uid] = savedPic;
          }
          _currentUser = UserModel.fromMap(map, uid);
          _userStreamController.add(_currentUser);
        }
      } catch (e) {
        debugPrint("Restore session error: $e");
      }
    }
  }

  /// Persists user profile picture and session to browser local storage
  void _persistUser(UserModel user) {
    _currentUser = user;
    if (user.email.isNotEmpty) {
      _registeredEmails.add(user.email.toLowerCase().trim());
      _preRegisteredEmails.add(user.email.toLowerCase().trim());
    }

    if (user.profilePicUrl.isNotEmpty) {
      _profilePicCache[user.uid] = user.profilePicUrl;
    }

    if (kIsWeb) {
      try {
        if (user.profilePicUrl.isNotEmpty) {
          WebStorage.localStorage['profile_pic_${user.uid}'] = user.profilePicUrl;
          WebStorage.localStorage['last_profile_pic'] = user.profilePicUrl;
        }
        WebStorage.localStorage['akila_lms_user'] = jsonEncode(user.toMap());
      } catch (e) {
        debugPrint("Persist user error: $e");
      }
    }
  }

  String _getSavedProfilePic(String uid, String fallbackPic) {
    if (_profilePicCache.containsKey(uid) && _profilePicCache[uid]!.isNotEmpty) {
      return _profilePicCache[uid]!;
    }
    if (kIsWeb) {
      try {
        final saved = WebStorage.localStorage['profile_pic_$uid'] ?? WebStorage.localStorage['last_profile_pic'];
        if (saved != null && saved.isNotEmpty) {
          _profilePicCache[uid] = saved;
          return saved;
        }
      } catch (_) {}
    }
    return fallbackPic;
  }

  void _listenToAuthState() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        if (_currentUser != null && kIsWeb && WebStorage.localStorage.containsKey('akila_lms_user')) {
          // Keep active restored session in web demo mode
          return;
        }
        _currentUser = null;
        _userStreamController.add(null);
      } else {
        try {
          final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists && doc.data() != null) {
            final userFromDoc = UserModel.fromMap(doc.data()!, firebaseUser.uid);
            final persistentPic = _getSavedProfilePic(firebaseUser.uid, userFromDoc.profilePicUrl);
            _currentUser = userFromDoc.copyWith(profilePicUrl: persistentPic);
          } else {
            final lowerEmail = (firebaseUser.email ?? '').toLowerCase();
            final isTeacher = lowerEmail.contains('akila') || lowerEmail.contains('admin') || lowerEmail.contains('teacher');
            final defaultPic = isTeacher ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '';
            final persistentPic = _getSavedProfilePic(firebaseUser.uid, firebaseUser.photoURL ?? defaultPic);

            _currentUser = UserModel(
              uid: firebaseUser.uid,
              role: isTeacher ? 'admin' : 'student',
              name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
              email: firebaseUser.email ?? '',
              phone: firebaseUser.phoneNumber ?? '',
              grade: isTeacher ? 'Teacher / Lecturer' : '2026 A/L',
              school: isTeacher ? 'Combined Maths Academy' : 'School Student',
              profilePicUrl: persistentPic,
            );
            await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toMap(), SetOptions(merge: true));
          }
          _persistUser(_currentUser!);
          _userStreamController.add(_currentUser);
        } catch (e) {
          debugPrint("AuthState fetch user error: $e");
        }
      }
    });
  }

  // Sign In with Firebase Email & Password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final lower = email.trim().toLowerCase();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: lower,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final userFromDoc = UserModel.fromMap(doc.data()!, uid);
        final persistentPic = _getSavedProfilePic(uid, userFromDoc.profilePicUrl);
        _currentUser = userFromDoc.copyWith(profilePicUrl: persistentPic);
      } else {
        final isTeacher = lower.contains('admin') || lower.contains('akila') || lower.contains('teacher');
        final defaultPic = isTeacher ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '';
        final persistentPic = _getSavedProfilePic(uid, defaultPic);

        _currentUser = UserModel(
          uid: uid,
          role: isTeacher ? 'admin' : 'student',
          name: email.split('@')[0].toUpperCase(),
          email: lower,
          phone: isTeacher ? '+94 71 999 8888' : '+94 77 123 4567',
          grade: isTeacher ? 'Teacher / Lecturer' : '2026 A/L',
          school: isTeacher ? 'Combined Maths Academy' : 'Royal College, Colombo',
          profilePicUrl: persistentPic,
        );
        await _firestore.collection('users').doc(uid).set(_currentUser!.toMap(), SetOptions(merge: true));
      }
      _persistUser(_currentUser!);
      _userStreamController.add(_currentUser);
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No account found for '$lower'. Please click 'New Register' to create your account.");
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception("Incorrect password. Please check your password or try again.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Invalid email address format.");
      }
      debugPrint("FirebaseAuthException signIn: ${e.code} - ${e.message}");
      return _signInDemoFallback(lower);
    } catch (e) {
      debugPrint("Firebase Auth signIn error: $e. Falling back to local authentication mode.");
      return _signInDemoFallback(lower);
    }
  }

  // Register New User with Firebase Email & Password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String grade,
    required String school,
    required String role,
  }) async {
    final lower = email.trim().toLowerCase();

    // Enforce 1 email only can add for 1 time
    final alreadyReg = await _isEmailAlreadyRegistered(lower);
    if (alreadyReg) {
      throw Exception("Registration Failed: '$email' is already registered. 1 email can only be registered 1 time. Please sign in instead.");
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: lower,
        password: password,
      );
      final uid = credential.user!.uid;
      final defaultPic = role == 'admin' ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '';
      final persistentPic = _getSavedProfilePic(uid, defaultPic);

      _currentUser = UserModel(
        uid: uid,
        role: role,
        name: name,
        email: lower,
        phone: phone,
        grade: grade,
        school: school,
        profilePicUrl: persistentPic,
      );
      await _firestore.collection('users').doc(uid).set(_currentUser!.toMap(), SetOptions(merge: true));
      _persistUser(_currentUser!);
      _userStreamController.add(_currentUser);
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _registeredEmails.add(lower);
        throw Exception("Registration Failed: '$email' is already registered. 1 email can only be registered 1 time. Please sign in.");
      } else if (e.code == 'weak-password') {
        throw Exception("Password is too weak. Please use at least 6 characters.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Invalid email address format.");
      }
      debugPrint("FirebaseAuthException signUp: ${e.code} - ${e.message}");
      return _signUpDemoFallback(
        name: name,
        email: lower,
        phone: phone,
        grade: grade,
        school: school,
        role: role,
      );
    } catch (e) {
      if (e.toString().contains("Registration Failed")) rethrow;
      debugPrint("Firebase Auth signUp error: $e. Falling back to local registration.");
      return _signUpDemoFallback(
        name: name,
        email: lower,
        phone: phone,
        grade: grade,
        school: school,
        role: role,
      );
    }
  }

  // Sign In with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw Exception("Google sign in cancelled");
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user!;
      final uid = firebaseUser.uid;
      final lower = (firebaseUser.email ?? '').trim().toLowerCase();

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final userFromDoc = UserModel.fromMap(doc.data()!, uid);
        final persistentPic = _getSavedProfilePic(uid, userFromDoc.profilePicUrl);
        _currentUser = userFromDoc.copyWith(profilePicUrl: persistentPic);
      } else {
        final isTeacher = lower.contains('akila') || lower.contains('admin');
        final defaultPic = firebaseUser.photoURL ?? (isTeacher ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '');
        final persistentPic = _getSavedProfilePic(uid, defaultPic);

        _currentUser = UserModel(
          uid: uid,
          role: isTeacher ? 'admin' : 'student',
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'Google User',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '+94 77 000 0000',
          grade: isTeacher ? 'Teacher / Lecturer' : '2026 A/L',
          school: isTeacher ? 'Combined Maths Academy' : 'Ananda College, Colombo',
          profilePicUrl: persistentPic,
        );
        await _firestore.collection('users').doc(uid).set(_currentUser!.toMap(), SetOptions(merge: true));
      }

      _persistUser(_currentUser!);
      _userStreamController.add(_currentUser);
      return _currentUser!;
    } catch (e) {
      debugPrint("Google Sign-In error: $e. Falling back to Google demo mode.");
      return _signInGoogleDemoFallback();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
    if (kIsWeb) {
      try {
        WebStorage.localStorage.remove('akila_lms_user');
      } catch (_) {}
    }
    _currentUser = null;
    _userStreamController.add(null);
  }

  // Update Profile
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required String grade,
    required String school,
    String? profilePicUrl,
  }) async {
    if (_currentUser == null) throw Exception("No active user session");

    final finalPicUrl = (profilePicUrl != null && profilePicUrl.isNotEmpty)
        ? profilePicUrl
        : _currentUser!.profilePicUrl;

    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      grade: grade,
      school: school,
      profilePicUrl: finalPicUrl,
    );

    _persistUser(_currentUser!);

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).set(_currentUser!.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore updateProfile error: $e");
    }

    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  void switchRole(String newRole) {
    if (_currentUser != null) {
      final defaultPic = newRole == 'admin' ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : _currentUser!.profilePicUrl;
      final persistentPic = _getSavedProfilePic(_currentUser!.uid, defaultPic);

      _currentUser = UserModel(
        uid: _currentUser!.uid,
        role: newRole,
        name: newRole == 'admin' ? 'Akila Jayaweera (Teacher)' : _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        grade: newRole == 'admin' ? 'Teacher / Lecturer' : '2026 A/L',
        school: newRole == 'admin' ? 'Combined Maths Academy' : _currentUser!.school,
        profilePicUrl: persistentPic,
      );
      _persistUser(_currentUser!);
      _userStreamController.add(_currentUser);
    }
  }

  UserModel _signInDemoFallback(String email) {
    final lowerEmail = email.toLowerCase().trim();
    final isTeacher = lowerEmail.contains('admin') || lowerEmail.contains('akila') || lowerEmail.contains('teacher');
    final uid = isTeacher ? 'adm_001' : 'std_${lowerEmail.hashCode.abs()}';
    final defaultPic = isTeacher ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
    final persistentPic = _getSavedProfilePic(uid, defaultPic);

    _currentUser = UserModel(
      uid: uid,
      role: isTeacher ? 'admin' : 'student',
      name: isTeacher ? 'Akila Jayaweera (Teacher)' : (email.isEmpty ? 'Kamal Perera' : email.split('@')[0].toUpperCase()),
      email: email.isEmpty ? 'student@akilamaths.lk' : email,
      phone: isTeacher ? '+94 71 999 8888' : '+94 77 123 4567',
      grade: isTeacher ? 'Teacher / Lecturer' : '2026 A/L',
      school: isTeacher ? 'Combined Maths Academy' : 'Ananda College, Colombo',
      profilePicUrl: persistentPic,
    );
    _persistUser(_currentUser!);
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  UserModel _signUpDemoFallback({
    required String name,
    required String email,
    required String phone,
    required String grade,
    required String school,
    required String role,
  }) {
    final lower = email.toLowerCase().trim();
    if (_registeredEmails.contains(lower)) {
      throw Exception("Registration Failed: '$email' is already registered. 1 email can only be registered 1 time.");
    }

    final uid = 'uid_${DateTime.now().millisecondsSinceEpoch}';
    final defaultPic = role == 'admin' ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '';
    final persistentPic = _getSavedProfilePic(uid, defaultPic);

    _currentUser = UserModel(
      uid: uid,
      role: role,
      name: name,
      email: email,
      phone: phone,
      grade: grade,
      school: school,
      profilePicUrl: persistentPic,
    );
    _persistUser(_currentUser!);
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  UserModel _signInGoogleDemoFallback() {
    final uid = 'google_std_1001';
    final persistentPic = _getSavedProfilePic(uid, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150');

    _currentUser = UserModel(
      uid: uid,
      role: 'student',
      name: 'Google User (Kamal Perera)',
      email: 'student.google@akilamaths.lk',
      phone: '+94 77 123 4567',
      grade: '2026 A/L',
      school: 'Ananda College, Colombo',
      profilePicUrl: persistentPic,
    );
    _persistUser(_currentUser!);
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }
}
