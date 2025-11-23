import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

class CaptchaData {
  const CaptchaData({required this.id, required this.imageUrl});

  final String id;
  final String imageUrl;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _tokenKey = 'backend_jwt';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late SharedPreferences _prefs;
  String? _backendToken;
  Map<String, dynamic>? _cachedUser;
  CaptchaData? _captcha;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _backendToken = prefs.getString(_tokenKey);
  }

  String? get backendToken => _backendToken;
  Map<String, dynamic>? get cachedUser => _cachedUser;
  CaptchaData? get currentCaptcha => _captcha;

  Future<Map<String, dynamic>> verifyOtp(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw AuthException('Unable to fetch Firebase token');
      }

      final backendResponse = await ApiService.instance.post(
        '/auth/phone/',
        body: {'token': idToken},
      );
      final backendJwt = backendResponse['token'] as String?;
      final user = backendResponse['user'] as Map<String, dynamic>?;

      if (backendJwt == null || user == null) {
        throw AuthException('Backend response invalid');
      }

      _backendToken = backendJwt;
      _cachedUser = user;
      await _prefs.setString(_tokenKey, backendJwt);
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Invalid OTP');
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final token = _backendToken;
    if (token == null) {
      throw AuthException('Please login again');
    }
    final user = await ApiService.instance.get('/auth/me/', token: token);
    _cachedUser = user;
    return user;
  }

  Future<CaptchaData> fetchCaptcha() async {
    final response = await ApiService.instance.get('/auth/captcha/');
    final captcha = CaptchaData(
      id: response['id'] as String? ?? '',
      imageUrl: response['image'] as String? ?? '',
    );
    _captcha = captcha;
    return captcha;
  }

  Future<void> verifyCaptcha({
    required String captchaId,
    required String text,
  }) async {
    await ApiService.instance.post(
      '/auth/captcha/verify/',
      body: {'id': captchaId, 'text': text},
    );
  }

  Future<void> registerUser({
    required String name,
    required String phoneNumber,
  }) async {
    await ApiService.instance.post(
      '/auth/register/',
      body: {'name': name, 'phone': phoneNumber},
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _backendToken = null;
    _cachedUser = null;
    await _prefs.remove(_tokenKey);
  }

  // Backwards compatibility if older code still calls logout.
  Future<void> logout() => signOut();

  /// Login with a test user for development/testing purposes
  Future<void> loginTestUser() async {
    _backendToken = 'test_token_12345';
    _cachedUser = {
      'id': 'test_user_1',
      'name': 'Test Farmer',
      'phone': '+919876543210',
      'role': 'farmer',
    };
    await _prefs.setString(_tokenKey, _backendToken!);
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
