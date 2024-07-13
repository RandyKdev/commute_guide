import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commute_guide/constants/routes.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/models/issue.dart';
import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/providers/base_provider.dart';
import 'package:commute_guide/repositories/auth_repository.dart';
import 'package:commute_guide/repositories/message_repository.dart';
import 'package:commute_guide/repositories/user_repository.dart';
// import 'package:commute_guide/route_arguments/after_signup_route_argument.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

final globalProvider = ChangeNotifierProvider(
  (ref) {
    return GlobalProvider(
      authRepository: ref.read(authRepository),
      navigationService: ref.read(navigationService),
      userRepository: ref.read(userRepository),
    );
  },
);

class GlobalProvider extends BaseProvider {
  AppUser? _user;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final NavigationService _navigationService;
  String? _id;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _issuesListen;

  List<CommuteIssue> _issues = [];

  set user(AppUser? user) {
    _user = user;
    if (user != null && user.getCurrentScheduledTrips.isNotEmpty) {
      setTimerForScheduledNotif();
    }
    if (user == null) {
      _issuesListen?.cancel();
    } else {
      _issuesListen?.cancel();
      listenToIssues(user);
    }
    notifyListeners();
  }

  AppUser? get user => _user;
  bool _auth = false;
  bool get isAuthenticated => user != null;

  GlobalProvider({
    required AuthRepository authRepository,
    required super.navigationService,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _navigationService = navigationService,
        _userRepository = userRepository {
    listenToUserChanges();
    _authRepository.userChanges.listen((_) => listenToUserChanges());
  }

  void listenToIssues(AppUser user) async {
    final stream = _userRepository.getIssuesStream();
    if (stream == null) return;

    _issuesListen = stream.listen((data) {
      final changedIssues = data.docChanges
          .map((e) => CommuteIssue.fromJson(e.doc.data()!))
          .toList();
      final notifs = changedIssues
          .where((e) =>
              _issues
                  .any((e1) => e1.id == e.id && !e1.accepted && e.accepted) &&
              (user.notificationPreferences ?? []).contains(e.issue))
          .toList();
      notifs.forEach((e) async {
        await initNotification();
        await setupFlutterNotifications();

        // print('Push Notif');

        showFlutterNotification(RemoteMessage(
          notification: RemoteNotification(
            title:
                '${e.issue == IssueEnum.accidents ? 'Accident' : e.issue == IssueEnum.naturalDisasters ? 'Natural Disaster' : e.issue == IssueEnum.obstructions ? 'Obstruction' : e.issue == IssueEnum.construction ? 'Construction' : e.issue == IssueEnum.event ? 'Event' : 'Issue'}${e.address == null ? '' : ' at ${e.address!.substring(
                    0,
                    e.address!.indexOf(','),
                  )}'}',
            body: e.description,
            android: const AndroidNotification(),
          ),
        ));
      });
      _issues = data.docs.map((e) => CommuteIssue.fromJson(e.data())).toList();
    });
  }

  void requiredUserAuth(AppUser user) async {
    if (_auth) {
      user = user;
      return;
    }
    _auth = true;
    listenToIssues(user);
// ···
    final LocalAuthentication auth = LocalAuthentication();
    // ···
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    if (!user.auth || !canAuthenticate) {
      _navigationService.popAllAndPushNamed(Routes.home);
      user = user;
      return;
    }

    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      _navigationService.popAllAndPushNamed(Routes.home);
      user = user;
      return;
    }

    try {
      // print('do');
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        options: const AuthenticationOptions(stickyAuth: true),
      );

      // print(didAuthenticate);

      if (!didAuthenticate) {
        exit(0);
      }

      _navigationService.popAllAndPushNamed(Routes.home);
      user = user;
      // ···
    } on PlatformException {
      // print('exception');
      exit(0);
      // ...
    } catch (e) {
      exit(0);
    }
  }

  void setTimerForScheduledNotif() async {
    final newId = const Uuid().v4();
    _id = newId;
    final now = DateTime.now();
    final trips = user!.getCurrentScheduledTrips
        .where((e) => e.scheduledAt.isAfter(now))
        .toList();
    if (trips.isEmpty) return;
    final trip = trips.first;
    Future.delayed(trip.scheduledAt.difference(now), () async {
      if (newId != _id) return;

      await initNotification();
      await setupFlutterNotifications();

      // print('Push Notif');

      showFlutterNotification(RemoteMessage(
        notification: RemoteNotification(
          title: 'Time to leave for ${trip.places.last.address.substring(
            0,
            trip.places.last.address.indexOf(','),
          )}',
          body:
              'Leave now to arrive at ${DateFormat('h:m a').format(DateTime.now().add(Duration(seconds: trip.duration.toInt())))}',
          android: const AndroidNotification(),
        ),
      ));

      setTimerForScheduledNotif();
    });
  }

  void listenToUserChanges() async {
    final oldUser = _user;
    _user = await _authRepository.checkAuthState();

    // Future.delayed(Duration.zero, () {
    if (_user == null && oldUser != null) {
      _navigationService.popAllAndPushNamed(Routes.login);
      user = user;
      return;
    }

    if (_user != null && oldUser == null) {
        requiredUserAuth(_user!);
    }
    final context = _navigationService.currentContext;
    if (!context.mounted) return;
    final location =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (location == Routes.splash) {
      _navigationService.popAllAndPushNamed(Routes.login);
      user = user;
      return;
    }
    user = user;
    notifyListeners();
    // });
  }
}
