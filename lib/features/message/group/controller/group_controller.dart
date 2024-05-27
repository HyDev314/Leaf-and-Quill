import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/providers/storage_repository_provider.dart';
import 'package:leaf_and_quill_app/core/utils/show_snackbar.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/message/group/repository/group_repository.dart';
import 'package:leaf_and_quill_app/models/message/group_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final groupControllerProvider =
    StateNotifierProvider<GroupController, bool>((ref) {
  final groupRepository = ref.watch(groupRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return GroupController(
    groupRepository: groupRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getGroupByIdProvider = StreamProvider.family((ref, String id) {
  return ref.watch(groupControllerProvider.notifier).getGroupById(id);
});

class GroupController extends StateNotifier<bool> {
  final GroupRepository _groupRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  GroupController(
      {required GroupRepository groupRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _groupRepository = groupRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createGroup(BuildContext context, String name, File? profilePic,
      List<String> uids) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    var groupId = const Uuid().v1();
    late String profileUrl;

    if (profilePic != null) {
      final res = await _storageRepository.storeFile(
        path: 'group',
        id: groupId,
        file: profilePic,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => profileUrl = r,
      );
    }

    GroupModel group = GroupModel(
      senderId: uid,
      name: name,
      groupId: groupId,
      lastMessage: '',
      groupPic: profileUrl,
      membersUid: [uid, ...uids],
      timeSent: DateTime.now(),
    );

    final res = await _groupRepository.createGroup(context, group);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      Routemaster.of(context).history.back();
    });
  }

  Stream<GroupModel> getGroupById(String id) {
    return _groupRepository.getGroupById(id);
  }
}
