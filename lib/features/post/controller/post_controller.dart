import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/enums/enums.dart';
import 'package:leaf_and_quill_app/core/providers/storage_repository_provider.dart';
import 'package:leaf_and_quill_app/core/utils/show_snackbar.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/notification/controller/notification_controller.dart';
import 'package:leaf_and_quill_app/features/post/repository/post_repository.dart';
import 'package:leaf_and_quill_app/models/comment_model.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getHotNewsProvider =
    StreamProvider.family((ref, List<CommunityModel> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getHotNews(communities);
});

final feedPostControllerProvider =
    StateNotifierProvider<FeedPostController, List<PostModel>>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  return FeedPostController(
    postRepository: postRepository,
  );
});

final communityPostControllerProvider =
    StateNotifierProvider<CommunityPostController, List<PostModel>>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  return CommunityPostController(postRepository: postRepository);
});

final userPostControllerProvider =
    StateNotifierProvider<UserPostController, List<PostModel>>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  return UserPostController(postRepository: postRepository);
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

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void sharePost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String type,
    String? link,
    File? file,
    String? description,
  }) async {
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    late PostModel post;

    if (file != null) {
      final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.id}',
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
          interest: 0,
          isApprove: selectedCommunity.mods.contains(user.uid),
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
        interest: 0,
        isApprove: selectedCommunity.mods.contains(user.uid),
        type: type,
        createdAt: DateTime.now(),
        isDeleted: false,
      );
    }

    final res = await _postRepository.addPost(post);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Đăng bài viết thành công! Đợi phê duyệt');
      Routemaster.of(context).pop();
    });
  }

  void deletePost({
    required BuildContext context,
    required PostModel post,
  }) async {
    post = post.copyWith(isDeleted: true);

    final res = await _postRepository.editPost(post);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Xóa bài viết thành công!');
      Routemaster.of(context).pop();
    });
  }

  void approvePost(
      {required BuildContext context, required PostModel post}) async {
    post = post.copyWith(isApprove: true);

    final res = await _postRepository.editPost(post);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Duyệt bài viết thành công!');
    });
  }

  void upvote(PostModel post) async {
    final uid = _ref.read(userProvider)!.uid;
    _ref
        .read(postControllerProvider.notifier)
        .updatePostInterest(post, TPI.upVote);
    _postRepository.upvote(post, uid);
  }

  void downvote(PostModel post) async {
    final uid = _ref.read(userProvider)!.uid;
    _ref
        .read(postControllerProvider.notifier)
        .updatePostInterest(post, TPI.downVote);
    _postRepository.downvote(post, uid);
  }

  Stream<PostModel> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  Stream<List<PostModel>> getHotNews(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.getHotNews(communities);
    }
    return Stream.value([]);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required PostModel post,
    File? file,
  }) async {
    final uid = _ref.read(userProvider)?.uid ?? '';
    String commentId = const Uuid().v1();

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

    _ref
        .read(notificationControllerProvider.notifier)
        .createNotification(context: context, commentId: commentId, post: post);

    _ref
        .read(postControllerProvider.notifier)
        .updatePostInterest(post, TPI.comment);
    final res = await _postRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Stream<List<CommentModel>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  Stream<CommentModel> getCommentById(String id) {
    return _postRepository.getCommentById(id);
  }

  void updatePostInterest(PostModel post, TPI interest) async {
    post = post.copyWith(interest: post.interest + interest.interest);

    final res = await _postRepository.updatePostInterest(post);
    res.fold((l) => null, (r) => null);
  }
}

class FeedPostController extends StateNotifier<List<PostModel>> {
  final PostRepository _postRepository;

  FeedPostController({
    required PostRepository postRepository,
  })  : _postRepository = postRepository,
        super([]);

  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;

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
}

class CommunityPostController extends StateNotifier<List<PostModel>> {
  final PostRepository _postRepository;

  CommunityPostController({required PostRepository postRepository})
      : _postRepository = postRepository,
        super([]);

  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;

  Future<void> fetchInitialCommunityPosts({
    required String id,
    required bool isApprove,
    String? type,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    List<PostModel> posts = [];

    if (type != null) {
      posts = await _postRepository.fetchUserCommunityPosts(
        id: id,
        limit: _limit,
        isApprove: isApprove,
        type: type,
      );
    } else {
      posts = await _postRepository.fetchUserCommunityPosts(
        id: id,
        limit: _limit,
        isApprove: isApprove,
      );
    }

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> refreshCommunityPosts(
      {required String id, required bool isApprove, String? type}) async {
    if (_isLoading) return;
    _isLoading = true;

    List<PostModel> posts = [];

    if (type != null) {
      posts = await _postRepository.fetchUserCommunityPosts(
        id: id,
        limit: _limit,
        isApprove: isApprove,
        type: type,
      );
    } else {
      posts = await _postRepository.fetchUserCommunityPosts(
        id: id,
        limit: _limit,
        isApprove: isApprove,
      );
    }

    state = posts;
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }

  Future<void> fetchMoreCommunityPosts(
      {required String id, required bool isApprove, String? type}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    final lastPost = state.isNotEmpty ? state.last : null;

    List<PostModel> posts = [];

    if (type != null) {
      posts = await _postRepository.fetchUserCommunityPosts(
        id: id,
        limit: _limit,
        isApprove: isApprove,
        lastPost: lastPost,
        type: type,
      );
    } else {
      posts = await _postRepository.fetchUserCommunityPosts(
        id: id,
        limit: _limit,
        isApprove: isApprove,
        lastPost: lastPost,
      );
    }

    if (posts.isNotEmpty) {
      state = [...state, ...posts];
    }
    _hasMore = posts.length == _limit;
    _isLoading = false;
  }
}

class UserPostController extends StateNotifier<List<PostModel>> {
  final PostRepository _postRepository;

  UserPostController({required PostRepository postRepository})
      : _postRepository = postRepository,
        super([]);

  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;

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
}
