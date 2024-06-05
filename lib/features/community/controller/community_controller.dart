import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';
import 'package:leaf_and_quill_app/core/errors/failures.dart';
import 'package:leaf_and_quill_app/core/providers/storage_repository_provider.dart';
import 'package:leaf_and_quill_app/core/utils/show_snackbar.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/repository/community_repository.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final userCommunitiesProvider = StreamProvider.family((ref, String uid) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities(uid);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getCommunityByIdProvider = StreamProvider.family((ref, String id) {
  return ref.watch(communityControllerProvider.notifier).getCommunityById(id);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final getSuggestCommunityPostsProvider = StreamProvider((ref) {
  return ref
      .read(communityControllerProvider.notifier)
      .getSuggestCommunityPosts();
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    String communityId = const Uuid().v1();

    CommunityModel community = CommunityModel(
        id: communityId,
        name: name,
        nameLowerCase: name.toLowerCase(),
        description: '',
        banner: AppConstants.bannerDefault,
        avatar: AppConstants.avatarDefault,
        members: [uid],
        admin: uid,
        mods: [uid],
        isDeleted: false);

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Tạo cộng đồng thành công!');
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(CommunityModel community, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.id, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.id, user.uid);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, 'Rời cộng đồng thành công!');
      } else {
        showSnackBar(context, 'Tham gia cộng đồng thành công!');
      }
    });
  }

  Stream<List<CommunityModel>> getUserCommunities(String uid) {
    print(uid);
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<CommunityModel> getCommunityById(String id) {
    return _communityRepository.getCommunityById(id);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required String? name,
    required String? description,
    required BuildContext context,
    required CommunityModel community,
  }) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.id,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.id,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    if (name != null) {
      community = community.copyWith(name: name);
      community = community.copyWith(nameLowerCase: name.toLowerCase());
    }

    if (description != null) {
      community = community.copyWith(description: description);
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).history.back(),
    );
  }

  void deleteCommunity({
    required BuildContext context,
    required CommunityModel community,
  }) async {
    state = true;

    community = community.copyWith(isDeleted: true);

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community Deleted successfully!');
      Routemaster.of(context).push('/');
    });
  }

  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(
      String communityId, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityId, uids);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<CommunityModel>> getSuggestCommunityPosts() {
    return _communityRepository.getSuggestCommunityPosts();
  }
}
