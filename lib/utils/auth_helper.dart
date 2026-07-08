import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthHelper {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '335206650251-uinrks2t4sro374vdqur4op1tg7r2a9b.apps.googleusercontent.com',
  );

  /// Menjalankan alur Google Sign-In, menukarnya dengan kredensial Firebase,
  /// dan membuat dokumen profil Firestore pengguna saat login pertama kali.
  static Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Memicu alur autentikasi
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Pengguna membatalkan alur sign-in
        return null;
      }

      // Mengambil detail autentikasi dari permintaan
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Membuat kredensial baru
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Setelah berhasil masuk, kembalikan UserCredential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Periksa apakah pengguna sudah ada di Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Jika pengguna belum ada, buat profil di Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'user_id': user.uid,
                'name': user.displayName ?? 'Google User',
                'email': user.email ?? '',
                'photo_url': user.photoURL,
                'created_at': FieldValue.serverTimestamp(),
              });
        }
      }

      return user;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat masuk dengan Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Mengeluarkan pengguna dari Firebase Auth dan Google Sign-In.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
