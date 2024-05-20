import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';
import 'package:leaf_and_quill_app/features/auth/controller/auth_controller.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';

class SignInWithGoogleButton extends ConsumerWidget {
  final bool isFromLogin;
  const SignInWithGoogleButton({super.key, this.isFromLogin = true});

  void signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle(context, isFromLogin);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(context, ref),
        icon: Image.asset(
          AppConstants.googleLogo,
          height: 30,
        ),
        label: Text(
          'Continue with Google',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.mainColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            )),
      ),
    );
  }
}
