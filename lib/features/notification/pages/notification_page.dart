import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/notification/controller/notification_controller.dart';
import 'package:leaf_and_quill_app/features/notification/widgets/notification_card.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(userProvider)!.uid;

    return SkeletonPage(
      title: Text(
        'Thông báo',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      bodyW: ref.watch(getUserNotificationsProvider(uid)).when(
            data: (data) {
              if (data.isEmpty) {
                return Center(
                    child: Text(
                  "Không có thông báo nào",
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 22,
                      ),
                )); // Debug log
              }
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  final notification = data[index];

                  return NotificationCard(notification: notification);
                },
              );
            },
            error: (error, stackTrace) {
              return ErrorPage(errorText: error.toString());
            },
            loading: () => const LoaderPage(),
          ),
    );
  }
}
