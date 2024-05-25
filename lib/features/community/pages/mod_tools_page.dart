import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsPage extends ConsumerWidget {
  final String id;
  const ModToolsPage({super.key, required this.id});

  void navigateToEditCommunity(BuildContext context, String name) {
    Routemaster.of(context).push('/edit-community/$id/$name');
  }

  void navigateToAddMods(BuildContext context) {
    Routemaster.of(context).push('/add-mods/$id');
  }

  void deleteCommunity(
      WidgetRef ref, BuildContext context, CommunityModel community) {
    ref
        .read(communityControllerProvider.notifier)
        .deleteCommunity(context: context, community: community);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SkeletonPage(
      title: Text(
        'Mod Tools',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      leadingW: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Routemaster.of(context).history.back();
          }),
      bodyW: ref.watch(getCommunityByIdProvider(id)).when(
            data: (community) => Center(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_moderator),
                    title: Text(
                      'Chỉnh sửa quyền quản lý',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    onTap: () => navigateToAddMods(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(
                      'Chỉnh sửa thông tin cộng đồng',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    onTap: () =>
                        navigateToEditCommunity(context, community.name),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dangerous_outlined),
                    title: Text(
                      'Xóa cộng đồng',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Xóa cộng đồng ?',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  fontSize: 22,
                                )),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Routemaster.of(context).pop(),
                            child: Text('Thoát',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontSize: 18,
                                    )),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteCommunity(ref, context, community);
                            },
                            child: Text('Xác nhận',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontSize: 18,
                                    )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            error: (error, stackTrace) =>
                ErrorPage(errorText: error.toString()),
            loading: () => const LoaderPage(),
          ),
    );
  }
}
