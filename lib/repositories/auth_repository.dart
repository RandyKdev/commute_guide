import 'package:commute_guide/constants/db_collections.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepository = Provider(
  (ref) => AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
    userRepository: ref.read(userRepository),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  const AuthRepository({
    required FirebaseFirestore firebaseFirestore,
    required FirebaseAuth firebaseAuth,
    required UserRepository userRepository,
  })  : _firebaseAuth = firebaseAuth,
        _firebaseFirestore = firebaseFirestore,
        _userRepository = userRepository;

  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  Future<void> forgotPassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<AppUser?> checkAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('signed-in') ?? false) {
        await _firebaseAuth.authStateChanges().first;
      }

      final user = _firebaseAuth.currentUser;

      if (user == null) return null;

      return _userRepository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('signed-in', false);
      await _firebaseAuth.signOut();
    } catch (e) {
      return;
    }
  }

  Future<AppUser?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) return null;

      final appUser = AppUser(
        id: user.uid,
        name: user.displayName,
        email: user.email,
        createdAt: DateTime.now(),
        fcmTokens: null,
        cyclingPreferences: const [],
        drivingPreferences: const [],
        favorites: const [],
        preferredTravelMode: TravelModeEnum.driving,
        recents: const [],
        scheduledTrips: const [],
        walkingPreferences: const [],
        notificationPreferences: const [...IssueEnum.values],
        auth: false,
      );
      await _firebaseFirestore
          .collection(DBCollections.users)
          .doc(user.uid)
          .set(appUser.toFullJson());
      return appUser;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }

  Future<AppUser?> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;
      final userDoc = await _firebaseFirestore
          .collection(DBCollections.users)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        final appUser = AppUser(
          id: user.uid,
          name: user.displayName,
          email: user.email,
          createdAt: null,
          fcmTokens: null,
          cyclingPreferences: const [],
          drivingPreferences: const [],
          favorites: const [],
          preferredTravelMode: TravelModeEnum.driving,
          recents: const [],
          scheduledTrips: const [],
          walkingPreferences: const [],
          notificationPreferences: const [...IssueEnum.values],
          auth: false,
        );
        await _firebaseFirestore
            .collection(DBCollections.users)
            .doc(user.uid)
            .set(appUser.toFullJson());

        return appUser;
      }

      final appUser = AppUser.fromJson(userDoc.data() ?? {});

      return appUser;
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }

  Future<AppUser?> logInWithCredential(AuthCredential credential) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) return null;
      final userDoc = await _firebaseFirestore
          .collection(DBCollections.users)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        final appUser = AppUser(
          id: user.uid,
          name: user.displayName,
          email: user.email,
          createdAt: null,
          fcmTokens: null,
          cyclingPreferences: const [],
          drivingPreferences: const [],
          favorites: const [],
          preferredTravelMode: TravelModeEnum.driving,
          recents: const [],
          scheduledTrips: const [],
          walkingPreferences: const [],
          notificationPreferences: const [...IssueEnum.values],
          auth: false,
        );
        await _firebaseFirestore
            .collection(DBCollections.users)
            .doc(user.uid)
            .set(appUser.toFullJson());

        return appUser;
      }

      final appUser = AppUser.fromJson(userDoc.data() ?? {});

      return appUser;
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }
}
