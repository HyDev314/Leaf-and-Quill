import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/core/utils/pick_image.dart';
import 'package:leaf_and_quill_app/features/message/group/controller/group_controller.dart';
import 'package:leaf_and_quill_app/features/message/group/widgets/select_members.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  File? groupPic;
  bool _isError = false;

  void selectImage() async {
    final image = await pickImage();

    if (image != null) {
      setState(() {
        groupPic = File(image.files.first.path!);
      });
    }
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && groupPic != null) {
      ref.read(groupControllerProvider.notifier).createGroup(
            context,
            groupNameController.text.trim(),
            groupPic,
            ref.read(selectedGroupContacts),
          );
      ref.read(selectedGroupContacts.state).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonPage(
      title: Text(
        'Tạo nhóm chat',
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
            onPressed: () {
              setState(() {
                _isError = groupNameController.text.isEmpty;
              });
              if (!_isError) {
                createGroup();
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
            child: const Text('Tạo'),
          ),
        ),
      ],
      bodyW: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                groupPic == null
                    ? const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                        ),
                        radius: 64,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(
                          groupPic!,
                        ),
                        radius: 64,
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: groupNameController,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'tên nhóm',
                  errorText: _isError ? 'Tên nhóm không được để trống' : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    borderSide: _isError
                        ? const BorderSide(color: AppPalette.redColor, width: 1)
                        : BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Thêm thành viên',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 18),
              ),
            ),
            const SelectMembers(),
          ],
        ),
      ),
    );
  }
}
