import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:leaf_and_quill_app/config/constants/firebase_constants.dart';
import 'package:leaf_and_quill_app/core/errors/failures.dart';
import 'package:leaf_and_quill_app/core/providers/firebase_provider.dart';
import 'package:leaf_and_quill_app/core/type_def.dart';
import 'package:leaf_and_quill_app/models/notification_model.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(firestore: ref.watch(firestoreProvider));
});

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _notifications =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  FutureVoid createNotification(NotificationModel notification) async {
    try {
      return right(
          _notifications.doc(notification.id).set(notification.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid markReadNotificationAsRead(String notificationId) async {
    try {
      return right(_notifications.doc(notificationId).update({'isRead': true}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String uid) {
    return _notifications
        .where('isDeleted', isEqualTo: false)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => NotificationModel.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // FutureVoid deleteNotificationByCommunity(
  //     String communityId) async {
  //   try {
  //     return right(
  //         _notifications.where('communityId', isEqualTo: communityId).);
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   } catch (e) {
  //     return left(Failure(e.toString()));
  //   }
  // }
}
