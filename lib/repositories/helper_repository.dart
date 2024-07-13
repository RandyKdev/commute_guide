import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final helperRepository = Provider(
  (ref) => HelperRepository(
    firebaseStorage: FirebaseStorage.instance,
  ),
);

class HelperRepository {
  // Stream<AppUser?> get user => firebaseAuth.userChanges().;
  final FirebaseStorage _firebaseStorage;

  const HelperRepository({
    required FirebaseStorage firebaseStorage,
  }) : _firebaseStorage = firebaseStorage;

  Future<String?> uploadFile({
    required File image,
    required String path,
  }) async {
    try {
      return await _firebaseStorage.ref(path).putFile(image).then(
            (taskSnapshot) => taskSnapshot.ref.getDownloadURL(),
          );
    } on FirebaseAuthException {
      // throw Failure(code: err.code, message: err.message!);
    } on PlatformException {
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }
}
