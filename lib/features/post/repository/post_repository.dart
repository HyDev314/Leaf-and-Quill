import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:leaf_and_quill_app/config/constants/firebase_constants.dart';
import 'package:leaf_and_quill_app/core/errors/failures.dart';
import 'package:leaf_and_quill_app/core/providers/firebase_provider.dart';
import 'package:leaf_and_quill_app/core/type_def.dart';
import 'package:leaf_and_quill_app/models/comment_model.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid addPost(PostModel post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(PostModel post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downvote(PostModel post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<PostModel> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map(
        (event) => PostModel.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editPost(PostModel post) async {
    try {
      return right(_posts.doc(post.id).update(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addComment(CommentModel comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommentModel>> getCommentsOfPost(String postId) {
    return _comments
        .where('isDeleted', isEqualTo: false)
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => CommentModel.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<CommentModel> getCommentById(String id) {
    return _comments.doc(id).snapshots().map(
        (event) => CommentModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<List<PostModel>> getHotNews(List<CommunityModel> communities) {
    return _posts
        .where('isDeleted', isEqualTo: false)
        .where('isApprove', isEqualTo: true)
        .where('communityId', whereIn: communities.map((e) => e.id).toList())
        .orderBy('interest', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => PostModel.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Future<List<PostModel>> fetchPosts({
    required List<CommunityModel> communities,
    required int limit,
    PostModel? lastPost,
  }) async {
    Query query = _posts
        .where('isDeleted', isEqualTo: false)
        .where('isApprove', isEqualTo: true)
        .where('communityId', whereIn: communities.map((e) => e.id).toList())
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastPost != null) {
      query = query.startAfterDocument(await _posts.doc(lastPost.id).get());
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<PostModel>> fetchUserPosts({
    required String uid,
    required int limit,
    PostModel? lastPost,
  }) async {
    Query query = _posts
        .where('isDeleted', isEqualTo: false)
        .where('isApprove', isEqualTo: true)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastPost != null) {
      query = query.startAfterDocument(await _posts.doc(lastPost.id).get());
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<PostModel>> fetchUserCommunityPosts({
    required String id,
    required int limit,
    required bool isApprove,
    String? type,
    PostModel? lastPost,
  }) async {
    Query query = _posts
        .where('isDeleted', isEqualTo: false)
        .where('isApprove', isEqualTo: isApprove)
        .where('communityId', isEqualTo: id)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    if (lastPost != null) {
      query = query.startAfterDocument(await _posts.doc(lastPost.id).get());
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  FutureVoid updatePostInterest(PostModel post) async {
    try {
      return right(_posts.doc(post.id).update({
        'interest': post.interest,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
