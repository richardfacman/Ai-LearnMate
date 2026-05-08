import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final user = UserModel(
      uid: cred.user!.uid,
      name: name.isNotEmpty ? name : "Unknown",
      email: cred.user!.email ?? email,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  Future<UserModel> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final snap =
    await _db.collection('users').doc(cred.user!.uid).get();

    if (!snap.exists) {
      final fallbackUser = UserModel(
        uid: cred.user!.uid,
        name: cred.user!.displayName ?? "Unknown",
        email: cred.user!.email ?? email,
        createdAt: DateTime.now(),
      );

      await _db.collection('users')
          .doc(fallbackUser.uid)
          .set(fallbackUser.toMap());

      return fallbackUser;
    }

    return UserModel.fromMap(snap.data()!);
  }

  Future<UserModel?> googleSignIn() async {
    final gUser = await GoogleSignIn().signIn();
    if (gUser == null) return null;

    final gAuth = await gUser.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final result = await _auth.signInWithCredential(cred);

    final user = UserModel(
      uid: result.user!.uid,
      name: result.user!.displayName ?? "Unknown",
      email: result.user!.email ?? "",
      photoUrl: result.user!.photoURL,
      createdAt: DateTime.now(),
    );

    await _db.collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));

    return user;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
