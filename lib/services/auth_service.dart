import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = .instance;
  static final currentUserNotifier = ValueNotifier<User?>(null);

  static void init() {
    // MANUAL BYPASS: Check the current user on boot
    currentUserNotifier.value = _auth.currentUser;

    // Keep the stream active for other platforms (like Android)
    // where it works perfectly
    _auth.authStateChanges().listen((User? user) {
      currentUserNotifier.value = user;
    });
  }

  // --- SIGN UP ---
  static Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // MANUAL BYPASS: Force the UI to update!
      currentUserNotifier.value = _auth.currentUser;

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // --- SIGN IN ---
  static Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // MANUAL BYPASS: Force the UI to update!
      currentUserNotifier.value = _auth.currentUser;

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // --- SIGN OUT ---
  static Future<void> signOut() async {
    await _auth.signOut();

    // MANUAL BYPASS: Force the UI to update!
    currentUserNotifier.value = null;
  }

  static String? get currentUserId => _auth.currentUser?.uid;
}
