import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = .instance;
  static final currentUserNotifier = ValueNotifier<User?>(null);
  static const String unimplementedErrorMessage =
      "Google Sign-In is not currently supported on Windows. "
      "Please use Email & Password.";

  static Future<void> init() async {
    try {
      await GoogleSignIn.instance.initialize();
    } on UnimplementedError {
      debugPrint(unimplementedErrorMessage);
    }

    if (_auth.currentUser != null && verifyEmail(_auth.currentUser!)) {
      currentUserNotifier.value = _auth.currentUser;
    }

    _auth.authStateChanges().listen((User? user) {
      if (user != null && verifyEmail(user)) {
        currentUserNotifier.value = user;
      } else {
        currentUserNotifier.value = null;
      }
    });
  }

  static bool verifyEmail(User user) {
    bool verifyProvider(UserInfo userInfo) {
      return userInfo.providerId == 'google.com';
    }

    return user.emailVerified || user.providerData.any(verifyProvider);
  }

  // --- EMAIL SIGN UP (WITH VERIFICATION) ---
  static Future<String?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send the verification link
      await cred.user?.sendEmailVerification();

      // Immediately sign them out locally so they are
      // forced to verify before entering
      await _auth.signOut();

      return "VERIFICATION_SENT"; // Special flag for our UI
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // --- EMAIL SIGN IN (WITH VERIFICATION CHECK) ---
  static Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!cred.user!.emailVerified) {
        await _auth.signOut();
        return "Please verify your email before logging in. Check your inbox!";
      }

      currentUserNotifier.value = cred.user;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // --- GOOGLE SIGN IN ---
  static Future<String?> signInWithGoogle() async {
    try {
      // Authentication (Triggers the new Credential Manager UI)
      final googleUser = await GoogleSignIn.instance.authenticate();

      // Authorization (Explicitly request scopes to get the Access Token)
      final authClient = googleUser.authorizationClient;
      final clientAuth = await authClient.authorizeScopes(['email', 'profile']);

      // Get the ID Token
      final googleAuth = googleUser.authentication;

      // Combine both tokens to build the Firebase Credential
      final credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      currentUserNotifier.value = cred.user;
      return null;
    } on UnimplementedError {
      return unimplementedErrorMessage;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to sign in with Google. $e";
    }
  }

  // --- SIGN OUT ---
  static Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
    currentUserNotifier.value = null;
  }

  static String? get currentUserId => _auth.currentUser?.uid;
}
