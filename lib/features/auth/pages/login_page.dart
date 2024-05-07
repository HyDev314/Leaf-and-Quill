import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';
import 'package:leaf_and_quill_app/core/common/loader.dart';
import 'package:leaf_and_quill_app/core/common/widgets/skeleton.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/features/auth/pages/widgets/sign_in_with_google_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return SkeletonPage(
      title: Text(''),
      action: Padding(
        padding: const EdgeInsets.only(right: 30),
        child: InkWell(
          onTap: () {},
          child: Row(
            children: [
              Text('Tiếng Việt',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: 16)),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppConstants.appLogo,
            height: 250,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Leaf & Quill',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(fontSize: 30),
            ),
          ),
          const SizedBox(height: 100),
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: const LoaderPage(),
                )
              : const SignInWithGoogleButton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: RichText(
              text: TextSpan(
                text: "Tự động đồng ý với ",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontSize: 12),
                children: const <TextSpan>[
                  TextSpan(
                    text: "Điều khoản sử dụng",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " và ",
                  ),
                  TextSpan(
                    text: "Điều khoản sủ dụng thông tin cá nhân",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " khi đăng ký.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isBack: true,
    );
  }
}
