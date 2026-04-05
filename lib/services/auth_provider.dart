import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String provider;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.provider,
  });

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }

  Map<String, dynamic> toJson() => {
    'uid': uid, 'displayName': displayName, 'email': email, 'provider': provider
  };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    uid: j['uid'], displayName: j['displayName'],
    email: j['email'], provider: j['provider'],
  );
}

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user        => _user;
  bool    get isLoading    => _isLoading;
  String? get error        => _error;
  bool    get isAuthenticated => _user != null;

  AuthProvider() { _loadSavedUser(); }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('current_user');
    if (raw != null) {
      _user = AppUser.fromJson(json.decode(raw));
      notifyListeners();
    }
  }

  Future<void> _saveUser(AppUser u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(u.toJson()));
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String e) { _error = e; _isLoading = false; notifyListeners(); }
  void _clearError()       { _error = null; }

  // ── Sign Up ─────────────────────────────────────────────────────────────────
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _setLoading(true); _clearError();
    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().isEmpty) { _setError('Please enter your full name.'); return false; }
    if (!email.contains('@') || !email.contains('.')) { _setError('Please enter a valid email address.'); return false; }
    if (password.length < 6) { _setError('Password must be at least 6 characters.'); return false; }

    // Check if account already exists
    final prefs = await SharedPreferences.getInstance();
    final accounts = json.decode(prefs.getString('accounts') ?? '{}') as Map;
    if (accounts.containsKey(email.toLowerCase())) {
      _setError('An account with this email already exists. Please sign in.'); return false;
    }

    // Save account
    accounts[email.toLowerCase()] = {
      'password': password, 'name': name.trim(),
      'uid': 'user_${DateTime.now().millisecondsSinceEpoch}'
    };
    await prefs.setString('accounts', json.encode(accounts));

    _user = AppUser(
      uid: accounts[email.toLowerCase()]['uid'],
      displayName: name.trim(),
      email: email.toLowerCase(),
      provider: 'email',
    );
    await _saveUser(_user!);
    _setLoading(false);
    return true;
  }

  // ── Sign In ──────────────────────────────────────────────────────────────────
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true); _clearError();
    await Future.delayed(const Duration(milliseconds: 600));

    if (!email.contains('@')) { _setError('Please enter a valid email address.'); return false; }
    if (password.isEmpty) { _setError('Please enter your password.'); return false; }

    final prefs = await SharedPreferences.getInstance();
    final accounts = json.decode(prefs.getString('accounts') ?? '{}') as Map;
    final acc = accounts[email.toLowerCase()];

    if (acc == null) { _setError('No account found with this email. Please sign up first.'); return false; }
    if (acc['password'] != password) { _setError('Incorrect password. Please try again.'); return false; }

    _user = AppUser(
      uid: acc['uid'], displayName: acc['name'],
      email: email.toLowerCase(), provider: 'email',
    );
    await _saveUser(_user!);
    _setLoading(false);
    return true;
  }

  // ── Google (demo) ────────────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading(true); _clearError();
    await Future.delayed(const Duration(milliseconds: 800));
    _user = const AppUser(uid: 'google_user', displayName: 'Google User',
        email: 'user@gmail.com', provider: 'google');
    await _saveUser(_user!);
    _setLoading(false);
    return true;
  }

  // ── Apple (demo) ─────────────────────────────────────────────────────────────
  Future<bool> signInWithApple() async {
    _setLoading(true); _clearError();
    await Future.delayed(const Duration(milliseconds: 800));
    _user = const AppUser(uid: 'apple_user', displayName: 'Apple User',
        email: 'user@icloud.com', provider: 'apple');
    await _saveUser(_user!);
    _setLoading(false);
    return true;
  }

  // ── Forgot Password ──────────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true); _clearError();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!email.contains('@')) { _setError('Please enter a valid email address.'); return false; }
    _setLoading(false);
    return true;
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _clearUser();
    _user = null;
    notifyListeners();
  }
}
