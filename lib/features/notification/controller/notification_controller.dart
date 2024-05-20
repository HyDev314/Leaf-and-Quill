import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/utils/show_snackbar.dart';
import 'package:leaf_and_quill_app/features/notification/repository/notification_repository.dart';
import 'package:leaf_and_quill_app/models/notification_model.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return NotificationController(notificationRepository: notificationRepository);
});

final getUserNotificationsProvider = StreamProvider.family((ref, String uid) {
  return ref
      .watch(notificationControllerProvider.notifier)
      .getUserNotifications(uid);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationRepository _notificationRepository;

  NotificationController(
      {required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
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

  Stream<List<NotificationModel>> getUserNotifications(String uid) {
    return _notificationRepository.getUserNotifications(uid);
  }
}
