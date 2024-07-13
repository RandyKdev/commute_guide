import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/avoid_enum.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/extensions/string_ext.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const PreferencesBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<PreferencesBottomSheetWidget> createState() =>
      _PreferencesBottomSheetWidgetState();
}

class _PreferencesBottomSheetWidgetState
    extends ConsumerState<PreferencesBottomSheetWidget> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      double temp = widget.scrollController.positions.firstOrNull == null
          ? 0
          : widget.scrollController.positions.first.pixels <= 0
              ? 0
              : 1;
      if (dividerOpacity != temp) {
        if (!mounted) return;
        setState(() {
          dividerOpacity = temp;
        });
      }
    });
  }

  double dividerOpacity = 0;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    final userGlobalProvider = ref.watch(globalProvider);
    final preference =
        userGlobalProvider.user!.preferredTravelMode ?? TravelModeEnum.driving;
    final drivingPreferences =
        userGlobalProvider.user!.drivingPreferences ?? [];
    final walkingPreferences =
        userGlobalProvider.user!.walkingPreferences ?? [];
    final cyclingPreferences =
        userGlobalProvider.user!.cyclingPreferences ?? [];
    final notificationPreferences =
        userGlobalProvider.user!.notificationPreferences ?? [];
    final auth = userGlobalProvider.user!.auth;
    return Container(
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      height: mainProvider.maxPanelHeight * MediaQuery.sizeOf(context).height,
      clipBehavior: Clip.hardEdge,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: Colors.white.withOpacity(.96),
            child: Column(
              children: [
                Container(
                  // color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.only(
                          left: mainProvider.leftPadding,
                          right: mainProvider.rightPadding,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Preferences',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.1),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: const Icon(
                                      CupertinoIcons.clear_thick,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: dividerOpacity,
                        child: Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.grey.withOpacity(.1),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Directions',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (ctx, index) {
                                      final travelMode =
                                          TravelModeEnum.values[index];
                                      return InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          final user =
                                              mainProvider.setDirectionPref(
                                            user: userGlobalProvider.user!,
                                            travelMode: travelMode,
                                          );
                                          userGlobalProvider.user = user;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      travelMode.name
                                                          .getWordsCapitalized,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (preference == travelMode)
                                                const Icon(
                                                  CupertinoIcons.checkmark_alt,
                                                  color: AppColors.primaryBlue,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (ctx, index) {
                                      return Divider(
                                        color: Colors.grey.withOpacity(.05),
                                        height: 1,
                                        indent: 20,
                                        thickness: 1,
                                      );
                                    },
                                    itemCount: TravelModeEnum.values.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Driving',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (ctx, index) {
                                      final avoid = AvoidEnum.values[index];
                                      return InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          if (!drivingPreferences
                                              .contains(avoid)) {
                                            drivingPreferences.add(avoid);
                                          } else {
                                            drivingPreferences.remove(avoid);
                                          }
                                          final user =
                                              mainProvider.setDrivingPrefs(
                                            user: userGlobalProvider.user!,
                                            avoids: drivingPreferences,
                                          );
                                          userGlobalProvider.user = user;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Avoid ${avoid.name.getUncloggedWords.getWordsCapitalized}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Switch(
                                                value: drivingPreferences
                                                    .contains(avoid),
                                                onChanged: (val) {
                                                  if (val) {
                                                    drivingPreferences
                                                        .add(avoid);
                                                  } else {
                                                    drivingPreferences
                                                        .remove(avoid);
                                                  }
                                                  final user = mainProvider
                                                      .setDrivingPrefs(
                                                    user: userGlobalProvider
                                                        .user!,
                                                    avoids: drivingPreferences,
                                                  );
                                                  userGlobalProvider.user =
                                                      user;
                                                },
                                                activeTrackColor:
                                                    AppColors.primaryBlue,
                                                inactiveThumbColor:
                                                    Colors.black,
                                                inactiveTrackColor:
                                                    Colors.grey.withOpacity(.1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (ctx, index) {
                                      return Divider(
                                        color: Colors.grey.withOpacity(.05),
                                        height: 1,
                                        indent: 20,
                                        thickness: 1,
                                      );
                                    },
                                    itemCount: AvoidEnum.values.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Walking',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (ctx, index) {
                                      final avoid = AvoidEnum.values[index];
                                      return InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          if (!walkingPreferences
                                              .contains(avoid)) {
                                            walkingPreferences.add(avoid);
                                          } else {
                                            walkingPreferences.remove(avoid);
                                          }
                                          final user =
                                              mainProvider.setWalkingPrefs(
                                            user: userGlobalProvider.user!,
                                            avoids: walkingPreferences,
                                          );
                                          userGlobalProvider.user = user;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Avoid ${avoid.name.getUncloggedWords.getWordsCapitalized}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Switch(
                                                value: walkingPreferences
                                                    .contains(avoid),
                                                onChanged: (val) {
                                                  if (val) {
                                                    walkingPreferences
                                                        .add(avoid);
                                                  } else {
                                                    walkingPreferences
                                                        .remove(avoid);
                                                  }
                                                  final user = mainProvider
                                                      .setWalkingPrefs(
                                                    user: userGlobalProvider
                                                        .user!,
                                                    avoids: walkingPreferences,
                                                  );
                                                  userGlobalProvider.user =
                                                      user;
                                                },
                                                activeTrackColor:
                                                    AppColors.primaryBlue,
                                                inactiveThumbColor:
                                                    Colors.black,
                                                inactiveTrackColor:
                                                    Colors.grey.withOpacity(.1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (ctx, index) {
                                      return Divider(
                                        color: Colors.grey.withOpacity(.05),
                                        height: 1,
                                        indent: 20,
                                        thickness: 1,
                                      );
                                    },
                                    itemCount: AvoidEnum.values.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Cycling',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (ctx, index) {
                                      final avoid = AvoidEnum.values[index];
                                      return InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          if (!cyclingPreferences
                                              .contains(avoid)) {
                                            cyclingPreferences.add(avoid);
                                          } else {
                                            cyclingPreferences.remove(avoid);
                                          }
                                          final user =
                                              mainProvider.setCyclingPrefs(
                                            user: userGlobalProvider.user!,
                                            avoids: cyclingPreferences,
                                          );
                                          userGlobalProvider.user = user;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Avoid ${avoid.name.getUncloggedWords.getWordsCapitalized}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Switch(
                                                value: cyclingPreferences
                                                    .contains(avoid),
                                                onChanged: (val) {
                                                  if (val) {
                                                    cyclingPreferences
                                                        .add(avoid);
                                                  } else {
                                                    cyclingPreferences
                                                        .remove(avoid);
                                                  }
                                                  final user = mainProvider
                                                      .setCyclingPrefs(
                                                    user: userGlobalProvider
                                                        .user!,
                                                    avoids: cyclingPreferences,
                                                  );
                                                  userGlobalProvider.user =
                                                      user;
                                                },
                                                activeTrackColor:
                                                    AppColors.primaryBlue,
                                                inactiveThumbColor:
                                                    Colors.black,
                                                inactiveTrackColor:
                                                    Colors.grey.withOpacity(.1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (ctx, index) {
                                      return Divider(
                                        color: Colors.grey.withOpacity(.05),
                                        height: 1,
                                        indent: 20,
                                        thickness: 1,
                                      );
                                    },
                                    itemCount: AvoidEnum.values.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Notifications',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (ctx, index) {
                                      final issue = IssueEnum.values[index];
                                      return InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          if (!notificationPreferences
                                              .contains(issue)) {
                                            notificationPreferences.add(issue);
                                          } else {
                                            notificationPreferences
                                                .remove(issue);
                                          }
                                          final user =
                                              mainProvider.setNotficationPrefs(
                                            user: userGlobalProvider.user!,
                                            issues: notificationPreferences,
                                          );
                                          userGlobalProvider.user = user;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      issue ==
                                                              IssueEnum
                                                                  .accidents
                                                          ? 'Accident'
                                                          : issue ==
                                                                  IssueEnum
                                                                      .naturalDisasters
                                                              ? 'Natural Disaster'
                                                              : issue ==
                                                                      IssueEnum
                                                                          .obstructions
                                                                  ? 'Obstruction'
                                                                  : issue ==
                                                                          IssueEnum
                                                                              .construction
                                                                      ? 'Construction'
                                                                      : issue ==
                                                                              IssueEnum.event
                                                                          ? 'Event'
                                                                          : 'Others',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Switch(
                                                value: notificationPreferences
                                                    .contains(issue),
                                                onChanged: (val) {
                                                  if (val) {
                                                    notificationPreferences
                                                        .add(issue);
                                                  } else {
                                                    notificationPreferences
                                                        .remove(issue);
                                                  }
                                                  final user = mainProvider
                                                      .setNotficationPrefs(
                                                    user: userGlobalProvider
                                                        .user!,
                                                    issues:
                                                        notificationPreferences,
                                                  );
                                                  userGlobalProvider.user =
                                                      user;
                                                },
                                                activeTrackColor:
                                                    AppColors.primaryBlue,
                                                inactiveThumbColor:
                                                    Colors.black,
                                                inactiveTrackColor:
                                                    Colors.grey.withOpacity(.1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (ctx, index) {
                                      return Divider(
                                        color: Colors.grey.withOpacity(.05),
                                        height: 1,
                                        indent: 20,
                                        thickness: 1,
                                      );
                                    },
                                    itemCount: IssueEnum.values.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Security',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: InkWell(
                                    splashColor: Colors.white,
                                    focusColor: Colors.white,
                                    hoverColor: Colors.white,
                                    highlightColor: Colors.white,
                                    onTap: () {
                                      final user = mainProvider.setAuthPrefs(
                                        user: userGlobalProvider.user!,
                                        auth: !auth,
                                      );
                                      userGlobalProvider.user = user;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 5,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Lock When Not In Use',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.left,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Switch(
                                            value: auth,
                                            onChanged: (val) {
                                              final user =
                                                  mainProvider.setAuthPrefs(
                                                user: userGlobalProvider.user!,
                                                auth: val,
                                              );
                                              userGlobalProvider.user = user;
                                            },
                                            activeTrackColor:
                                                AppColors.primaryBlue,
                                            inactiveThumbColor: Colors.black,
                                            inactiveTrackColor:
                                                Colors.grey.withOpacity(.1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: mainProvider.bottomPadding),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
