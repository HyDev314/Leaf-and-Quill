import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:leaf_and_quill_app/config/constants/firebase_constants.dart';
import 'package:leaf_and_quill_app/core/errors/failures.dart';
import 'package:leaf_and_quill_app/core/providers/firebase_provider.dart';
import 'package:leaf_and_quill_app/core/type_def.dart';
import 'package:leaf_and_quill_app/models/message/group_model.dart';

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(firestore: ref.watch(firestoreProvider)),
);

class GroupRepository {
  final FirebaseFirestore _firestore;

  GroupRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _groups =>
      _firestore.collection(FirebaseConstants.groupsCollection);

  FutureVoid createGroup(BuildContext context, GroupModel group) async {
    try {
      return right(_groups.doc(group.groupId).set(group.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<GroupModel> getGroupById(String id) {
    return _groups.doc(id).snapshots().map(
        (event) => GroupModel.fromMap(event.data() as Map<String, dynamic>));
  }
}
