import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/core/enums/enums.dart';
import 'package:leaf_and_quill_app/core/utils/pick_image.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/features/post/controller/post_controller.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:leaf_and_quill_app/themes/theme.dart';
import 'package:routemaster/routemaster.dart';

class AddPostPage extends ConsumerStatefulWidget {
  final String? communityId;
  const AddPostPage({super.key, this.communityId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostPageState();
}

class _AddPostPageState extends ConsumerState<AddPostPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? imageFile;
  List<CommunityModel> communities = [];
  CommunityModel? selectedCommunity;
  PostEnum? postType;
  bool _isError = false;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        imageFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).sharePost(
          context: context,
          title: titleController.text.trim(),
          link: linkController.text.trim(),
          description: descriptionController.text.trim(),
          file: imageFile,
          selectedCommunity: selectedCommunity ?? communities[0],
          type: postType?.type ?? PostEnum.type1.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    final currentUser = ref.watch(userProvider)!;

    return SkeletonPage(
      title: Text(
        'Tạo bài viết mới',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 22),
      ),
      leadingW: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Routemaster.of(context).history.back();
          }),
      actionWs: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TextButton(
            onPressed: () {
              setState(() {
                _isError = titleController.text.isEmpty;
              });
              if (!_isError) {
                sharePost();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18))),
              backgroundColor: AppPalette.mainColor,
              foregroundColor: AppPalette.whiteColor,
              textStyle: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(fontSize: 16),
            ),
            child: const Text('Đăng bài'),
          ),
        ),
      ],
      bodyW: isLoading == []
          ? const LoaderPage()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Tiêu đề',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: titleController,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'tên tiêu đề',
                      errorText: _isError ? 'Nhập tiêu đề bài viết' : null,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                        borderSide: _isError
                            ? const BorderSide(
                                color: AppPalette.redColor, width: 1)
                            : BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                    maxLength: 21,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Link',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: linkController,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'gắn link',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 35),
                  Text(
                    'Nội dung',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: descriptionController,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'nội dung bài viết',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 35),
                  Text(
                    'Cộng đồng',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  ref.watch(userCommunitiesProvider(currentUser.uid)).when(
                        data: (data) {
                          communities = data;

                          if (data.isEmpty) {
                            return const SizedBox();
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: currentTheme.cardTheme.surfaceTintColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: DropdownButton(
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(fontSize: 18),
                              value: selectedCommunity ?? data[0],
                              items: data
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedCommunity = val;
                                });
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) => ErrorPage(
                          errorText: error.toString(),
                        ),
                        loading: () => const LoaderPage(),
                      ),
                  const SizedBox(height: 35),
                  Text(
                    'Loại bài viết',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: currentTheme.cardTheme.surfaceTintColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton(
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(fontSize: 18),
                      value: postType ?? PostEnum.values[0],
                      items: PostEnum.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.type),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          postType = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    'Ảnh',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: selectBannerImage,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10),
                      dashPattern: const [10, 4],
                      strokeCap: StrokeCap.round,
                      color: currentTheme.textTheme.displaySmall!.color!,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: imageFile != null
                            ? Image.file(imageFile!)
                            : const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),
    );
  }
}
