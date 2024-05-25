import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/community/controller/community_controller.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:routemaster/routemaster.dart';

class CreateCommunityPage extends ConsumerStatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityPageState();
}

class _CreateCommunityPageState extends ConsumerState<CreateCommunityPage> {
  bool _isError = false;

  final communityNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    ref.read(communityControllerProvider.notifier).createCommunity(
          communityNameController.text.trim(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return SkeletonPage(
      title: Text(
        'Tạo cộng đồng',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22,
            ),
      ),
      leadingW: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Routemaster.of(context).history.back();
          }),
      bodyW: isLoading
          ? const LoaderPage()
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Tên cộng đồng',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: communityNameController,
                    onSubmitted: (value) {
                      setState(() {
                        _isError = communityNameController.text.isEmpty;
                      });
                      if (!_isError) {
                        createCommunity();
                      }
                    },
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'tên cộng đồng',
                      errorText:
                          _isError ? 'Tên cộng đồng không được để trống' : null,
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
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isError = communityNameController.text.isEmpty;
                      });
                      if (!_isError) {
                        createCommunity();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppPalette.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        )),
                    child: Text('Tạo',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }
}
