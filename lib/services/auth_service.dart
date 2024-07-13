import 'dart:convert';

import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/repositories/auth_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final authService = Provider(
  (ref) => AuthService(
    authRepository: ref.read(authRepository),
    googleSignIn: GoogleSignIn(
      // clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
    ),
  ),
);

class AuthService {
  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn;

  AuthService({
    required AuthRepository authRepository,
    required GoogleSignIn googleSignIn,
  })  : _authRepository = authRepository,
        _googleSignIn = googleSignIn;

  Future<AppUser?> signInWithGoogle() async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return null;
      }

      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final authResult = await _authRepository.logInWithCredential(
        credential,
      );
      // final user = authResult.user;

      if (authResult == null) {
        // CSMSnackBarError(title: 'google_sign_in.error'.tr);
        // loadingGoogle = false;
        // update();
        return null;
      }

      return authResult;
    } catch (e) {
      return null;
    }
  }

  Future<AppUser?> signInWithApple() async {
    try {
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final rawNonce = generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.userIdentifier == null) {
        return null;
      }
      // String fullName =
      //     '${appleCredential.givenName} ${appleCredential.familyName}';
      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await _authRepository.logInWithCredential(
        oauthCredential,
      );

      // final user = authResult.user;
      // try {
      //   user?.updateDisplayName(fullName);
      // } catch (err) {
      //   print(err);
      // }

      if (authResult == null) {
        return null;
      }

      // print("User Name: ${user.displayName}");
      // print("User Email ${user.email}");
      return authResult;
    } catch (e) {
      return null;
    }
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
