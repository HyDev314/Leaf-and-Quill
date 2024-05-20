import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:leaf_and_quill_app/config/constants/firebase_constants.dart';
import 'package:leaf_and_quill_app/core/errors/failures.dart';
import 'package:leaf_and_quill_app/core/providers/firebase_provider.dart';
import 'package:leaf_and_quill_app/core/type_def.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(CommunityModel community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }

      return right(_communities.doc(community.id).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String id, String userId) async {
    try {
      return right(_communities.doc(id).update({
        'members': FieldValue.arrayUnion([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String id, String userId) async {
    try {
      return right(_communities.doc(id).update({
        'members': FieldValue.arrayRemove([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> getUserCommunities(String uid) {
    return _communities
        .where('isDeleted', isEqualTo: false)
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<CommunityModel> communities = [];
      for (var doc in event.docs) {
        communities
            .add(CommunityModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<CommunityModel> getCommunityById(String id) {
    return _communities.doc(id).snapshots().map((event) =>
        CommunityModel.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(CommunityModel community) async {
    try {
      return right(_communities.doc(community.id).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> searchCommunity(String query) {
    String lowerCaseQuery = query.toLowerCase();

    return _communities
        .where('isDeleted', isEqualTo: false)
        .where(
          'nameLowerCase',
          isGreaterThanOrEqualTo: lowerCaseQuery.isEmpty ? 0 : lowerCaseQuery,
          isLessThan: lowerCaseQuery.isEmpty
              ? null
              : lowerCaseQuery.substring(0, lowerCaseQuery.length - 1) +
                  String.fromCharCode(
                    lowerCaseQuery.codeUnitAt(lowerCaseQuery.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<CommunityModel> communities = [];
      for (var community in event.docs) {
        communities.add(
            CommunityModel.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> getSuggestCommunityPosts() {
    return _communities
        .where('isDeleted', isEqualTo: false)
        .orderBy('memberCount', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => CommunityModel.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }
}
