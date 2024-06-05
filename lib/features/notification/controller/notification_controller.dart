import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/utils/show_snackbar.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/notification/repository/notification_repository.dart';
import 'package:leaf_and_quill_app/models/notification_model.dart';
import 'package:leaf_and_quill_app/models/post_model.dart';
import 'package:uuid/uuid.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return NotificationController(
    notificationRepository: notificationRepository,
    ref: ref,
  );
});

final getUserNotificationsProvider = StreamProvider.family((ref, String uid) {
  return ref
      .watch(notificationControllerProvider.notifier)
      .getUserNotifications(uid);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationRepository _notificationRepository;
  final Ref _ref;

  NotificationController(
      {required NotificationRepository notificationRepository,
      required Ref ref})
      : _notificationRepository = notificationRepository,
        _ref = ref,
        super(false);

  void markReadNotificationAsRead(
      {required BuildContext context, required String notificationId}) async {
    state = true;
    final res = await _notificationRepository
        .markReadNotificationAsRead(notificationId);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => print('Đã đọc thông báo'),
    );
  }

  void createNotification({
    required BuildContext context,
    required String commentId,
    required PostModel post,
  }) async {
    final uid = _ref.read(userProvider)?.uid ?? '';
    String notificationId = const Uuid().v1();

    if (uid != post.uid) {
      NotificationModel notification = NotificationModel(
          id: notificationId,
          uid: post.uid,
          commentId: commentId,
          createdAt: DateTime.now(),
          isRead: false,
          isDeleted: false);

      final res =
          await _notificationRepository.createNotification(notification);
      res.fold((l) => showSnackBar(context, l.message), (r) => null);
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String uid) {
    return _notificationRepository.getUserNotifications(uid);
  }
}
