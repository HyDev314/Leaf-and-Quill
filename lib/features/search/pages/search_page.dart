import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final searchTextController = TextEditingController();

  void navigateToCommunity(BuildContext context, String id) {
    Routemaster.of(context).push('/r/$id');
  }

  void searchCommunityByName(WidgetRef ref, String communityName) {
    ref
        .read(communityControllerProvider.notifier)
        .searchCommunity(communityName);
  }

  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonPage(
      title: Text(
        'Tìm kiếm cộng đồng',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      bodyW: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 60,
                      child: Icon(
                        Icons.search_rounded,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchTextController,
                        onSubmitted: (value) => setState(() {
                          searchCommunityByName(ref, value);
                        }),
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 18,
                                ),
                        cursorColor: Colors.blue,
                        decoration: InputDecoration.collapsed(
                          border: InputBorder.none,
                          hintText: 'Tìm kiếm',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  fontSize: 18, color: AppPalette.greyColor),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: AppPalette.mainColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.navigate_next_rounded,
                            size: 30,
                            color: AppPalette.whiteColor,
                          ),
                          onPressed: () => setState(() {
                            searchCommunityByName(
                                ref, searchTextController.text);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ref.watch(getSuggestCommunityPostsProvider).when(
                  data: (communities) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cộng đồng nổi bật',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 15),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: communities.length,
                          itemBuilder: (BuildContext context, int index) {
                            final community = communities[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(community.avatar),
                                ),
                                title: Text(
                                  'r/${community.name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(
                                        fontSize: 18,
                                      ),
                                ),
                                onTap: () =>
                                    navigateToCommunity(context, community.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  error: (error, stackTrace) => ErrorPage(
                    errorText: error.toString(),
                  ),
                  loading: () => const LoaderPage(),
                ),
            ref.watch(searchCommunityProvider(searchTextController.text)).when(
                  data: (communities) {
                    if (communities.isEmpty) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết quả tìm kiếm',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 15),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: communities.length,
                            itemBuilder: (BuildContext context, int index) {
                              final community = communities[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(community.avatar),
                                  ),
                                  title: Text(
                                    'r/${community.name}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                          fontSize: 18,
                                        ),
                                  ),
                                  onTap: () => navigateToCommunity(
                                      context, community.id),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  error: (error, stackTrace) => ErrorPage(
                    errorText: error.toString(),
                  ),
                  loading: () => const LoaderPage(),
                ),
          ],
        ),
      ),
    );
  }
}
