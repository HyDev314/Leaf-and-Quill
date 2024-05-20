import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';
import 'package:leaf_and_quill_app/features/home/widgets/bottom_navigation_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _page = 0;

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppConstants.tabWidgets[_page],
      // bottomNavigationBar: BottomNavigationBar(
      //   iconSize: 27,
      //   currentIndex: _page,
      //   onTap: onPageChanged,
      //   items: const [
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.search_rounded), label: 'Tìm kiếm'),
      //     BottomNavigationBarItem(icon: Icon(Icons.eco_rounded), label: ''),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.account_circle_rounded), label: ''),
      //   ],
      // ),
      bottomNavigationBar:
          BottomNavigationBarW(currentIndex: _page, onTap: onPageChanged),
    );
  }
}
