import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/avoid_enum.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/extensions/string_ext.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class AvoidBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  final List<AvoidEnum> avoidances;
  const AvoidBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
    required this.avoidances,
  });

  @override
  ConsumerState<AvoidBottomSheetWidget> createState() =>
      _AvoidBottomSheetWidgetState();
}

class _AvoidBottomSheetWidgetState
    extends ConsumerState<AvoidBottomSheetWidget> {
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
    avoidances = [...widget.avoidances];
  }

  double dividerOpacity = 0;
  List<AvoidEnum> avoidances = [];

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
                                ButtonWidget(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: 'Cancel',
                                  buttonType: ButtonTypeEnum.textButton,
                                ),
                                const Expanded(
                                  child: Text(
                                    'Avoid',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ButtonWidget(
                                  onTap: () {
                                    Navigator.of(context).pop(avoidances);
                                  },
                                  text: 'Apply',
                                  buttonType: ButtonTypeEnum.textButton,
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
                          color: Colors.grey.withOpacity(.2),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: mainProvider.leftPadding,
                        right: mainProvider.rightPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (ctx, index) {
                                  final avoid = AvoidEnum.values[index];
                                  return InkWell(
                                    splashColor: Colors.white,
                                    focusColor: Colors.white,
                                    hoverColor: Colors.white,
                                    highlightColor: Colors.white,
                                    onTap: () {
                                      if (!avoidances.contains(avoid)) {
                                        avoidances.add(avoid);
                                      } else {
                                        avoidances.remove(avoid);
                                      }
                                      setState(() {});
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
                                            value: avoidances.contains(avoid),
                                            onChanged: (val) {
                                              if (val) {
                                                avoidances.add(avoid);
                                              } else {
                                                avoidances.remove(avoid);
                                              }
                                              setState(() {});
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
                                  );
                                },
                                separatorBuilder: (ctx, index) {
                                  return Divider(
                                    color: Colors.grey.withOpacity(.1),
                                    height: 1,
                                    indent: 20,
                                    thickness: 1,
                                  );
                                },
                                itemCount: AvoidEnum.values.length),
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
