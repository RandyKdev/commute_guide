import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/favorites_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/preferences_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/user_issues_bottom_sheet_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:math' as math;

class AccountBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const AccountBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<AccountBottomSheetWidget> createState() =>
      _AccountBottomSheetWidgetState();
}

class _AccountBottomSheetWidgetState
    extends ConsumerState<AccountBottomSheetWidget> {
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

    return Container(
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      height:
          math.min(310 + mainProvider.bottomPadding, mainProvider.screenHeight),
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
                Column(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.person_crop_circle,
                                      color: Colors.grey,
                                      size: 45,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ref
                                                  .read(globalProvider)
                                                  .user
                                                  ?.name ??
                                              '',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            height: 1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          ref
                                                  .read(globalProvider)
                                                  .user
                                                  ?.email ??
                                              '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            height: 1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: InkWell(
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
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          showMaterialModalBottomSheet(
                                            context: context,
                                            isDismissible: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            )),
                                            backgroundColor: Colors.transparent,
                                            builder: (ctx) {
                                              return FavoritesBottomSheetWidget(
                                                changeMainProvider:
                                                    widget.changeMainProvider,
                                                scrollController:
                                                    ModalScrollController.of(
                                                        ctx)!,
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Icon(
                                                  CupertinoIcons.star_fill,
                                                  color: AppColors.primaryBlue,
                                                  size: 17,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Favorites',
                                                      style: TextStyle(
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
                                              const Icon(
                                                CupertinoIcons.right_chevron,
                                                size: 15,
                                                color: AppColors.grey,
                                              ),
                                              // SizedBox(width: 15),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey.withOpacity(.1),
                                        height: 1,
                                        indent: 55,
                                        thickness: 1,
                                      ),
                                      InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          showMaterialModalBottomSheet(
                                            context: context,
                                            isDismissible: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                            backgroundColor: Colors.transparent,
                                            builder: (ctx) {
                                              return UserIssuesBottomSheetWidget(
                                                changeMainProvider:
                                                    widget.changeMainProvider,
                                                scrollController:
                                                    ModalScrollController.of(
                                                        ctx)!,
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .exclamationmark_bubble_fill,
                                                  color: AppColors.red,
                                                  size: 17,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Issues',
                                                      style: TextStyle(
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
                                              const Icon(
                                                CupertinoIcons.right_chevron,
                                                size: 15,
                                                color: AppColors.grey,
                                              ),
                                              // SizedBox(width: 15),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey.withOpacity(.1),
                                        height: 1,
                                        indent: 55,
                                        thickness: 1,
                                      ),
                                      InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          showMaterialModalBottomSheet(
                                            context: context,
                                            isDismissible: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            )),
                                            backgroundColor: Colors.transparent,
                                            builder: (ctx) {
                                              return PreferencesBottomSheetWidget(
                                                changeMainProvider:
                                                    widget.changeMainProvider,
                                                scrollController:
                                                    ModalScrollController.of(
                                                        ctx)!,
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Icon(
                                                  CupertinoIcons.gear_solid,
                                                  color: AppColors.primaryBlue,
                                                  size: 17,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Preferences',
                                                      style: TextStyle(
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
                                              const Icon(
                                                CupertinoIcons.right_chevron,
                                                size: 15,
                                                color: AppColors.grey,
                                              ),
                                              // SizedBox(width: 15),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey.withOpacity(.05),
                                        height: 1,
                                        indent: 55,
                                        thickness: 1,
                                      ),
                                      InkWell(
                                        splashColor: Colors.white,
                                        focusColor: Colors.white,
                                        hoverColor: Colors.white,
                                        highlightColor: Colors.white,
                                        onTap: () {
                                          mainProvider.signOut();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Icon(
                                                  Icons.logout_outlined,
                                                  color: AppColors.red,
                                                  size: 17,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Sign Out',
                                                      style: TextStyle(
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
                                              const Icon(
                                                CupertinoIcons.right_chevron,
                                                size: 15,
                                                color: AppColors.grey,
                                              ),
                                              // SizedBox(width: 15),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
