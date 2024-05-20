import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:leaf_and_quill_app/core/errors/failures.dart';
import 'package:leaf_and_quill_app/core/providers/storage_repository_provider.dart';
import 'package:leaf_and_quill_app/core/utils/show_snackbar.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/user_profile/repository/user_repository.dart';
import 'package:leaf_and_quill_app/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final searchUserProvider = StreamProvider.family((ref, String query) {
  return ref.watch(userProfileControllerProvider.notifier).searchUser(query);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController(
      {required UserProfileRepository userProfileRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editProfile({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
    required String? description,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'users/profile', id: user.uid, file: profileFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'users/banner', id: user.uid, file: bannerFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }

    user = user.copyWith(name: name);
    user = user.copyWith(nameLowerCase: name.toLowerCase());

    if (description != null) {
      user = user.copyWith(description: description);
    }

    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).history.back();
      },
    );
  }

  void addFriend(UserModel userModel, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;
    if (userModel.friends.contains(user.uid)) {
      res = await _userProfileRepository.unFriend(userModel.uid, user.uid);
      res = await _userProfileRepository.unFriend(user.uid, userModel.uid);
    } else {
      res = await _userProfileRepository.addFriend(userModel.uid, user.uid);
      res = await _userProfileRepository.addFriend(user.uid, userModel.uid);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (userModel.friends.contains(user.uid)) {
        showSnackBar(context, 'Hủy kết bạn thành công!');
      } else {
        showSnackBar(context, 'Kết bạn thành công!');
      }
    });
  }

  Stream<List<UserModel>> searchUser(String query) {
    return _userProfileRepository.searchUser(query);
  }
}
