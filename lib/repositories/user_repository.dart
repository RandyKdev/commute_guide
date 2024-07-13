import 'dart:io';

import 'package:commute_guide/constants/db_collections.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/models/issue.dart';
import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/repositories/helper_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final userRepository = Provider(
  (ref) => UserRepository(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
    helperRepository: ref.read(helperRepository),
  ),
);

class UserRepository {
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _firebaseAuth;
  final HelperRepository _helperRepository;

  const UserRepository({
    required FirebaseFirestore firebaseFirestore,
    required FirebaseAuth firebaseAuth,
    required HelperRepository helperRepository,
  })  : _firebaseAuth = firebaseAuth,
        _firebaseFirestore = firebaseFirestore,
        _helperRepository = helperRepository;

  // Stream<AppUser?> get user => firebaseAuth.userChanges().;

  Future<bool> saveUser(AppUser user) async {
    try {
      await _firebaseFirestore.collection(DBCollections.users).doc(user.id).set(
            user.toFullJson(),
            SetOptions(merge: true),
          );

      return true;
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return false;
  }

  Future<Iterable<AppUser>> getAllUsers() async {
    try {
      final userDocs =
          await _firebaseFirestore.collection(DBCollections.users).get();

      return userDocs.docs.map((e) => AppUser.fromJson(e.data())).toList();
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return [];
  }

  Future<AppUser?> getUser(String userID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firebaseFirestore
          .collection(DBCollections.users)
          .doc(userID)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return AppUser.fromJson(userDoc.data() as Map<String, dynamic>);
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }

  Future<AppUser?> getCurrentUser() async {
    if (_firebaseAuth.currentUser?.uid == null) return null;
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firebaseFirestore
          .collection(DBCollections.users)
          .doc(_firebaseAuth.currentUser!.uid)
          .get();

      if (!userDoc.exists) {
        final appUser = AppUser(
          id: _firebaseAuth.currentUser!.uid,
          name: _firebaseAuth.currentUser!.displayName,
          email: _firebaseAuth.currentUser!.email,
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
            .doc(_firebaseAuth.currentUser!.uid)
            .set(appUser.toFullJson());

        userDoc = await _firebaseFirestore
            .collection(DBCollections.users)
            .doc(_firebaseAuth.currentUser!.uid)
            .get();
      }

      return AppUser.fromJson(userDoc.data() as Map<String, dynamic>);
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await _firebaseFirestore
          .collection(DBCollections.users)
          .doc(user.id)
          .update(user.toUpdateJson());
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
  }

  // Future<String?> uploadProfilePicture(File profilePicture) async {
  //   try {
  //     final profilePictureId = const Uuid().v4();
  //     final path =
  //         '${DBCollections.profileImages}/${_firebaseAuth.currentUser?.uid}/$profilePictureId.jpg';
  //     return await _helperRepository.uploadFile(
  //       image: profilePicture,
  //       path: path,
  //     );
  //   } on FirebaseAuthException {
  //     // throw Failure(code: err.code, message: err.message!);
  //   } on PlatformException {
  //     // throw Failure(code: err.code, message: err.message!);
  //   }
  //   return null;
  // }

  Future<List<String>> uploadImagesForIssue(List<File> pics) async {
    try {
      final ups = pics.map((e) {
        final profilePictureId = const Uuid().v4();
        final path =
            'issue_images/${_firebaseAuth.currentUser?.uid}/$profilePictureId.jpg';
        return _helperRepository.uploadFile(
          image: e,
          path: path,
        );
      });
      final result = await Future.wait(ups);
      return result.where((e) => e != null).toList().cast<String>();
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return [];
  }

  Future<CommuteIssue?> uploadIssue(CommuteIssue issue) async {
    try {
      final doc =
          await _firebaseFirestore.collection('issues').add(issue.toFullJson());
      await doc.update({'id': doc.id});
      return issue.copy(id: doc.id);
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }

  Future<List<CommuteIssue>> getApprovedIssues() async {
    try {
      final docs = await _firebaseFirestore
          .collection('issues')
          .where('accepted', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .get();
      return docs.docs.map((e) => CommuteIssue.fromJson(e.data())).toList();
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return [];
  }

  Future<List<CommuteIssue>> getUserIssues(String userId) async {
    try {
      final docs = await _firebaseFirestore
          .collection('issues')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
      return docs.docs.map((e) => CommuteIssue.fromJson(e.data())).toList();
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return [];
  }

  Future<bool> deleteIssue(CommuteIssue issue) async {
    try {
      await _firebaseFirestore.collection('issues').doc(issue.id).delete();
      return true;
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return false;
  }

  Future<void> trackCurrentTrip(CommuteTrip trip) async {
    try {
      await _firebaseFirestore.collection('trips').doc(trip.id).set(
          trip.toFullJson(),
          SetOptions(
            merge: true,
          ));
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return;
  }

  Future<void> stopTrackingTrip(CommuteTrip trip) async {
    try {
      await _firebaseFirestore.collection('trips').doc(trip.id).delete();
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return;
  }

  Future<bool> shouldSendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      if (_firebaseAuth.currentUser?.emailVerified == true) {
        return false;
      }
      await _firebaseAuth.currentUser?.sendEmailVerification();
      return true;
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return true;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getTripStream(String id) {
    try {
      return _firebaseFirestore.collection('trips').doc(id).snapshots();
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getIssuesStream() {
    try {
      return _firebaseFirestore.collection('issues').snapshots();
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }
}
