import 'package:flutter/material.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _delaySplash();
  }

  _delaySplash() async {
    await Future.delayed(const Duration(seconds: 10), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset(
              AppConstants.appLogo,
              height: 300,
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
          ],
        ),
      ),
    );
  }
}
