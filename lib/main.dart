import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/constants/global.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/repositories/message_repository.dart';
import 'package:commute_guide/router/router.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await initNotification();
  await setupFlutterNotifications();

  // Check if you received the link via `getInitialLink` first
  final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    // Example of using the dynamic link to push the user to a different screen
    dynamicLinks = deepLink.pathSegments;
  }

  runApp(const ProviderScope(child: CommuteGuideApp()));
}

class CommuteGuideApp extends ConsumerStatefulWidget {
  const CommuteGuideApp({super.key});

  @override
  ConsumerState<CommuteGuideApp> createState() => _CommuteGuideAppState();
}

class _CommuteGuideAppState extends ConsumerState<CommuteGuideApp> {
  late GoRouter router;

  @override
  void initState() {
    super.initState();
    router = generateRouterDelegate(ref);
    ref.read(navigationService).navigatorKey =
        router.routerDelegate.navigatorKey;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(globalProvider);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Commute Guide',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      color: AppColors.primaryBlue,
    );
  }
}
