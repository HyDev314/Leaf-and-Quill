import 'package:flutter/material.dart';
import 'package:leaf_and_quill_app/features/feed/pages/feed_page.dart';
import 'package:leaf_and_quill_app/features/menu/pages/menu_page.dart';
import 'package:leaf_and_quill_app/features/notification/pages/notification_page.dart';
import 'package:leaf_and_quill_app/features/search/pages/search_page.dart';

class AppConstants {
  static const String imagePath = 'assets/images/';

  static const bannerDefault =
      'https://img.freepik.com/free-vector/gradient-dynamic-blue-lines-background_23-2148995756.jpg?w=996&t=st=1714882478~exp=1714883078~hmac=2ed9f057c760a35adb6ba1fde118e8baf2083021bd2f582b1604c13c1f6cdd72';
  static const avatarDefault =
      'https://static.vecteezy.com/system/resources/previews/026/966/960/non_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg';

  static const List<String> topics = [
    'Tán gẫu',
    'Học tập',
    'Blah blah',
  ];

  static const noConnectionErrorMessage = 'Không có kết nối mạng!';

  static List<Widget> tabWidgets = [
    const FeedPage(),
    const SearchPage(),
    const NotificationPage(),
    const MenuPage(),
  ];

  static const String fontFamily = 'Nunito';

  static const String googleLogo = '${imagePath}google_logo.png';
  static const String appLogo = '${imagePath}app_logo.png';
}
