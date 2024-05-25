import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/error.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/core/utils/pick_image.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/models/community_model.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:leaf_and_quill_app/themes/theme.dart';
import 'package:routemaster/routemaster.dart';

class EditCommunityPage extends ConsumerStatefulWidget {
  final String id;
  final String name;

  const EditCommunityPage({super.key, required this.id, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityPageState();
}

class _EditCommunityPageState extends ConsumerState<EditCommunityPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? bannerFile;
  File? profileFile;
  bool _isError = false;

  @override
  void initState() {
    nameController.text = widget.name;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    descriptionController.dispose();
  }

  void selectBannerImage() async {
    final image = await pickImage();

    if (image != null) {
      setState(() {
        bannerFile = File(image.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final image = await pickImage();

    if (image != null) {
      setState(() {
        profileFile = File(image.files.first.path!);
      });
    }
  }

  void save(CommunityModel community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          context: context,
          community: community,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return ref.watch(getCommunityByIdProvider(widget.id)).when(
          data: (community) => SkeletonPage(
            title: Text(
              'Chỉnh sửa',
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 22,
                  ),
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
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text('Lưu thay đổi cộng đồng ?',
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
                            setState(() {
                              _isError = nameController.text.isEmpty;
                            });
                            if (!_isError) {
                              Routemaster.of(context).pop();
                              save(community);
                            }
                          },
                          child: Text('Lưu',
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
                  child: const Text('Lưu'),
                ),
              ),
            ],
            bodyW: isLoading
                ? const LoaderPage()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text('Ảnh bìa cộng đồng',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(fontSize: 18)),
                        ),
                        GestureDetector(
                          onTap: selectBannerImage,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(18),
                            dashPattern: const [10, 4],
                            strokeCap: StrokeCap.round,
                            color: currentTheme.textTheme.displayLarge!.color!,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                image: bannerFile != null
                                    ? DecorationImage(
                                        image: FileImage(bannerFile!),
                                        fit: BoxFit.cover)
                                    : DecorationImage(
                                        image: NetworkImage(community.banner),
                                        fit: BoxFit.cover),
                              ),
                              child: const Center(
                                child:
                                    Icon(Icons.camera_alt_outlined, size: 40),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 35),
                          child: Text('Ảnh đại diện cộng đồng',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(fontSize: 18)),
                        ),
                        GestureDetector(
                          onTap: selectProfileImage,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(40),
                            dashPattern: const [10, 4],
                            strokeCap: StrokeCap.round,
                            color: currentTheme.textTheme.displayLarge!.color!,
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: profileFile != null
                                  ? CircleAvatar(
                                      backgroundImage: FileImage(profileFile!),
                                      radius: 32,
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(community.avatar),
                                      radius: 32,
                                    ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 35),
                          child: Text('Tên cộng đồng',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(fontSize: 18)),
                        ),
                        TextField(
                          controller: nameController,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Tên cộng đồng',
                            errorText: _isError
                                ? 'Tên cộng đồng không được để trống'
                                : null,
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
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text('Mô tả cộng đồng',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(fontSize: 18)),
                        ),
                        TextField(
                          controller: descriptionController,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Mô tả cộng đồng',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.all(10),
                          ),
                          maxLength: 21,
                        ),
                      ],
                    ),
                  ),
          ),
          loading: () => const LoaderPage(),
          error: (error, stackTrace) => ErrorPage(
            errorText: error.toString(),
          ),
        );
  }
}
