import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> signUp(String name, String email, String password, {String? photoUrl}) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = cred.user;
    final uid = fbUser?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();

    final user = UserModel(
      uid: uid,
      name: name.isNotEmpty ? name : (fbUser?.displayName ?? "Student"),
      email: fbUser?.email ?? email,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    return user;
  }

  Future<UserModel> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = cred.user;
    final uid = fbUser?.uid ?? '';

    final snap = await _db.collection('users').doc(uid).get();

    if (!snap.exists || snap.data() == null) {
      final fallbackUser = UserModel(
        uid: uid,
        name: fbUser?.displayName ?? "Student",
        email: fbUser?.email ?? email,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(fallbackUser.uid).set(fallbackUser.toMap(), SetOptions(merge: true));
      return fallbackUser;
    }

    return UserModel.fromMap(snap.data()!);
  }

  Future<UserModel?> googleSignIn() async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        final gUser = await GoogleSignIn().signIn();
        if (gUser == null) return null;

        final gAuth = await gUser.authentication;
        final cred = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        credential = await _auth.signInWithCredential(cred);
      }

      final fbUser = credential.user;
      if (fbUser == null) return null;

      final user = UserModel(
        uid: fbUser.uid,
        name: fbUser.displayName ?? "Student",
        email: fbUser.email ?? "",
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      return user;
    } catch (e) {
      if (kIsWeb) {
        try {
          final googleProvider = GoogleAuthProvider();
          final credential = await _auth.signInWithProvider(googleProvider);
          final fbUser = credential.user;
          if (fbUser == null) return null;

          final user = UserModel(
            uid: fbUser.uid,
            name: fbUser.displayName ?? "Student",
            email: fbUser.email ?? "",
            photoUrl: fbUser.photoURL,
            createdAt: DateTime.now(),
          );

          await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
          return user;
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<UserModel?> facebookSignIn() async {
    try {
      final facebookProvider = FacebookAuthProvider();
      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(facebookProvider);
      } else {
        credential = await _auth.signInWithProvider(facebookProvider);
      }

      final fbUser = credential.user;
      if (fbUser == null) return null;

      final user = UserModel(
        uid: fbUser.uid,
        name: fbUser.displayName ?? "Facebook Student",
        email: fbUser.email ?? "",
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> githubSignIn() async {
    try {
      final githubProvider = GithubAuthProvider();
      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(githubProvider);
      } else {
        credential = await _auth.signInWithProvider(githubProvider);
      }

      final fbUser = credential.user;
      if (fbUser == null) return null;

      final user = UserModel(
        uid: fbUser.uid,
        name: fbUser.displayName ?? "GitHub Student",
        email: fbUser.email ?? "",
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> linkedInSignIn() async {
    try {
      final linkedinProvider = OAuthProvider('linkedin.com');
      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(linkedinProvider);
      } else {
        credential = await _auth.signInWithProvider(linkedinProvider);
      }

      final fbUser = credential.user;
      if (fbUser == null) return null;

      final user = UserModel(
        uid: fbUser.uid,
        name: fbUser.displayName ?? "LinkedIn Student",
        email: fbUser.email ?? "",
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
