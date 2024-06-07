import 'package:flutter/material.dart';
import 'package:leaf_and_quill_app/core/common/splash.dart';
import 'package:leaf_and_quill_app/features/auth/pages/login_page.dart';
import 'package:leaf_and_quill_app/features/community/pages/add_mods_page.dart';
import 'package:leaf_and_quill_app/features/community/pages/approve_posts_screen.dart';
import 'package:leaf_and_quill_app/features/community/pages/community_page.dart';
import 'package:leaf_and_quill_app/features/community/pages/create_community_page.dart';
import 'package:leaf_and_quill_app/features/community/pages/edit_community_page.dart';
import 'package:leaf_and_quill_app/features/community/pages/mod_tools_page.dart';
import 'package:leaf_and_quill_app/features/home/pages/home_page.dart';
import 'package:leaf_and_quill_app/features/message/chat/pages/chat_screen.dart';
import 'package:leaf_and_quill_app/features/message/group/pages/create_group_screen.dart';
import 'package:leaf_and_quill_app/features/message/message_page.dart';
import 'package:leaf_and_quill_app/features/message/select_contacts/pages/select_contacts_page.dart';
import 'package:leaf_and_quill_app/features/post/pages/add_post_page.dart';
import 'package:leaf_and_quill_app/features/post/pages/post_details_page.dart';
import 'package:leaf_and_quill_app/features/user_profile/pages/edit_profile_page.dart';
import 'package:leaf_and_quill_app/features/user_profile/pages/profile_page.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginPage()),
});

final splashRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: SplashPage()),
});

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomePage()),
    '/create-community': (_) =>
        const MaterialPage(child: CreateCommunityPage()),
    '/r/:id': (route) => MaterialPage(
            child: CommunityPage(
          id: route.pathParameters['id']!,
        )),
    '/mod-tools/:id': (routeData) => MaterialPage(
            child: ModToolsPage(
          id: routeData.pathParameters['id']!,
        )),
    '/approve-posts/:id': (routeData) => MaterialPage(
            child: ApprovePostScreen(
          id: routeData.pathParameters['id']!,
        )),
    '/edit-community/:id': (routeData) {
      return MaterialPage(
          child: EditCommunityPage(
        id: routeData.pathParameters['id']!,
      ));
    },
    '/add-mods/:id': (routeData) => MaterialPage(
            child: AddModsPage(
          id: routeData.pathParameters['id']!,
        )),
    '/u/:uid': (routeData) => MaterialPage(
            child: ProfilePage(
          uid: routeData.pathParameters['uid']!,
        )),
    '/edit-profile/:uid': (routeData) => MaterialPage(
            child: EditProfilePage(
          uid: routeData.pathParameters['uid']!,
        )),
    '/add-post': (_) => const MaterialPage(child: AddPostPage()),
    '/add-post-cId/:cId': (routeData) => MaterialPage(
            child: AddPostPage(
          communityId: routeData.pathParameters['cId']!,
        )),
    '/m': (_) => const MaterialPage(child: MessagePage()),
    '/post/:postId/details': (routeData) => MaterialPage(
            child: PostDetailsPage(
          postId: routeData.pathParameters['postId']!,
        )),

    //message
    '/select-contacts': (_) => const MaterialPage(child: SelectContactsPage()),
    '/chat/:id/:isGroupChat': (routeData) => MaterialPage(
            child: ChatScreen(
          id: routeData.pathParameters['id']!,
          isGroupChat:
              routeData.pathParameters['isGroupChat']!.toLowerCase() != 'false',
        )),

    '/create_group': (_) => const MaterialPage(child: CreateGroupScreen()),
  },
);
