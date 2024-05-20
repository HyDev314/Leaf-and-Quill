import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class AddModsPage extends ConsumerStatefulWidget {
  final String id;
  const AddModsPage({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsPageState();
}

class _AddModsPageState extends ConsumerState<AddModsPage> {
  Set<String> uids = {};
  int ctr = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void backToCommunity(BuildContext context) {
    Routemaster.of(context).replace('/r/${widget.id}');
  }

  void backToModTools(BuildContext context) {
    Routemaster.of(context).replace('/mod-tools/${widget.id}');
  }

  void saveMods(BuildContext context) {
    ref.read(communityControllerProvider.notifier).addMods(
          widget.id,
          uids.toList(),
          context,
        );
    backToCommunity(context);
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonPage(
      title: Text('Quản trị viên',
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 22,
              )),
      leadingW: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Routemaster.of(context).history.back();
          }),
      actionW: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: IconButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Lưu thay đổi quản trị viên ?',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 20,
                      )),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Routemaster.of(context).pop(),
                  child: Text('Thoát',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 18,
                          )),
                ),
                TextButton(
                  onPressed: () => saveMods(context),
                  child: Text('Lưu',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 18,
                          )),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.done, size: 25),
        ),
      ),
      bodyW: ref.watch(getCommunityByIdProvider(widget.id)).when(
            data: (community) => ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (BuildContext context, int index) {
                final memberUid = community.members[index];

                return ref.watch(getUserDataProvider(memberUid)).when(
                      data: (user) {
                        if (community.mods.contains(memberUid) &&
                            ctr == index) {
                          uids.add(memberUid);
                        }
                        ctr++;
                        return CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                              addUid(user.uid);
                            } else {
                              removeUid(user.uid);
                            }
                          },
                          title: Text(
                            user.name,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 20,
                                ),
                          ),
                        );
                      },
                      error: (error, stackTrace) => ErrorPage(
                        errorText: error.toString(),
                      ),
                      loading: () => const LoaderPage(),
                    );
              },
            ),
            error: (error, stackTrace) => ErrorPage(
              errorText: error.toString(),
            ),
            loading: () => const LoaderPage(),
          ),
    );
  }
}
