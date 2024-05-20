import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/providers/storage_repository_provider.dart';
import 'package:leaf_and_quill_app/core/utils/show_snackbar.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/notification/repository/notification_repository.dart';
import 'package:leaf_and_quill_app/features/post/repository/post_repository.dart';
import 'package:leaf_and_quill_app/models/comment_model.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/models/notification_model.dart';
import 'package:leaf_and_quill_app/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, List<PostModel>>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    notificationRepository: notificationRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

final getCommentByIdProvider = StreamProvider.family((ref, String id) {
  return ref.watch(postControllerProvider.notifier).getCommentById(id);
});

class PostController extends StateNotifier<List<PostModel>> {
  final NotificationRepository _notificationRepository;
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController(
      {required PostRepository postRepository,
      required NotificationRepository notificationRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _notificationRepository = notificationRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super([]);

  void sharePost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String type,
    String? link,
    File? file,
    String? description,
  }) async {
    state = [];
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    late PostModel post;

    if (file != null) {
      final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}',
        id: postId,
        file: file,
      );

      imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
        post = PostModel(
          id: postId,
          title: title,
          link: link ?? '',
          description: description ?? '',
          image: r,
          communityId: selectedCommunity.id,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          uid: user.uid,
          type: type,
          createdAt: DateTime.now(),
          isDeleted: false,
        );
      });
    } else {
      post = PostModel(
        id: postId,
        title: title,
        link: link ?? '',
        description: description ?? '',
        image: '',
        communityId: selectedCommunity.id,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        uid: user.uid,
        type: type,
        createdAt: DateTime.now(),
        isDeleted: false,
      );
    }

    final res = await _postRepository.addPost(post);
    state = [post, ...state];
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  void deletePost({
    required BuildContext context,
    required PostModel post,
  }) async {
    post = post.copyWith(isDeleted: true);

    final res = await _postRepository.editPost(post);
    state = state.where((p) => p.id != post.id).toList();
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post Deleted successfully!');
      Routemaster.of(context).pop();
    });
  }

  void upvote(PostModel post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(PostModel post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  Stream<PostModel> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required PostModel post,
    File? file,
  }) async {
    final uid = _ref.read(userProvider)?.uid ?? '';
    String commentId = const Uuid().v1();
    String notificationId = const Uuid().v1();

    late CommentModel comment;

    if (file != null) {
      final imageRes = await _storageRepository.storeFile(
        path: 'comments/${post.communityId}/${post.uid}',
        id: commentId,
        file: file,
      );

      imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
        comment = CommentModel(
          id: commentId,
          text: text,
          image: r,
          createdAt: DateTime.now(),
          postId: post.id,
          userId: uid,
          isDeleted: false,
        );
      });
    } else {
      comment = CommentModel(
        id: commentId,
        text: text,
        image: '',
        createdAt: DateTime.now(),
        postId: post.id,
        userId: uid,
        isDeleted: false,
      );
    }

    if (uid != post.uid) {
      NotificationModel notification = NotificationModel(
          id: notificationId,
          uid: post.uid,
          commentId: commentId,
          createdAt: DateTime.now(),
          isRead: false,
          isDeleted: false);

      final res2 =
          await _notificationRepository.createNotification(notification);
      res2.fold((l) => showSnackBar(context, l.message), (r) => null);
    }

    final res1 = await _postRepository.addComment(comment);
    res1.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Stream<List<CommentModel>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  Stream<CommentModel> getCommentById(String id) {
    return _postRepository.getCommentById(id);
  }

  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;

  //Feed_Page
  Future<void> fetchInitialPosts(List<CommunityModel> communities) async {
    if (_isLoading) return;
    _isLoading = true;

    final posts = await _postRepository.fetchPosts(
      communities: communities,
      limit: _limit,
    );

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> refreshPosts(List<CommunityModel> communities) async {
    if (_isLoading) return;
    _isLoading = true;

    final posts = await _postRepository.fetchPosts(
      communities: communities,
      limit: _limit,
    );

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> fetchMorePosts(List<CommunityModel> communities) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    final lastPost = state.isNotEmpty ? state.last : null;
    final posts = await _postRepository.fetchPosts(
      communities: communities,
      limit: _limit,
      lastPost: lastPost,
    );

    if (posts.isNotEmpty) {
      state = [...state, ...posts];
    }
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  //User_profile_Page
  Future<void> fetchInitialUserPosts(String uid) async {
    if (_isLoading) return;
    _isLoading = true;

    final posts = await _postRepository.fetchUserPosts(
      uid: uid,
      limit: _limit,
    );

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> refreshUserPosts(String uid) async {
    if (_isLoading) return;
    _isLoading = true;

    final posts = await _postRepository.fetchUserPosts(
      uid: uid,
      limit: _limit,
    );

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> fetchMoreUserPosts(String uid) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    final lastPost = state.isNotEmpty ? state.last : null;
    final posts = await _postRepository.fetchUserPosts(
      uid: uid,
      limit: _limit,
      lastPost: lastPost,
    );

    if (posts.isNotEmpty) {
      state = [...state, ...posts];
    }
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  //User_profile_Page
  Future<void> fetchInitialCommunityPosts(String id) async {
    if (_isLoading) return;
    _isLoading = true;

    final posts = await _postRepository.fetchUserCommunityPosts(
      id: id,
      limit: _limit,
    );

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> refreshCommunityPosts(String id) async {
    if (_isLoading) return;
    _isLoading = true;

    final posts = await _postRepository.fetchUserCommunityPosts(
      id: id,
      limit: _limit,
    );

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> fetchMoreCommunityPosts(String id) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    final lastPost = state.isNotEmpty ? state.last : null;
    final posts = await _postRepository.fetchUserCommunityPosts(
      id: id,
      limit: _limit,
      lastPost: lastPost,
    );

    if (posts.isNotEmpty) {
      state = [...state, ...posts];
    }
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }
}
