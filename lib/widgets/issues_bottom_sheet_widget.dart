import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/models/issue.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/add_issue_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/issue_list_tile_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class IssuesBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const IssuesBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<IssuesBottomSheetWidget> createState() =>
      _IssuesBottomSheetWidgetState();
}

class _IssuesBottomSheetWidgetState
    extends ConsumerState<IssuesBottomSheetWidget> {
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
    init();
  }

  void init() async {
    issues =
        await ref.read(widget.changeMainProvider).getListOfApprovedIssues();
    loading = false;
    setState(() {});
  }

  double dividerOpacity = 0;
  List<CommuteIssue> issues = [];
  bool loading = true;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
   ref.watch(globalProvider);

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
                                        'Issues',
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
                if (loading)
                  const Expanded(
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  )
                else if (issues.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No issues reported yet'),
                    ),
                  )
                else
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
                              clipBehavior: Clip.hardEdge,
                              child: Column(
                                children: issues.map((issue) {
                                  return IssueListTileWidget(
                                    key: ValueKey(issue),
                                    index: null,
                                    changeMainProvider:
                                        widget.changeMainProvider,
                                    onTap: () async {},
                                    issue: issue,
                                    isEditing: false,
                                    onDelete: null,
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(.2),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: mainProvider.leftPadding,
                    right: mainProvider.rightPadding,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: ButtonWidget(
                              onTap: () async {
                                await showMaterialModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  )),
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) {
                                    return AddIssueBottomSheetWidget(
                                      changeMainProvider:
                                          widget.changeMainProvider,
                                      scrollController:
                                          ModalScrollController.of(ctx)!,
                                    );
                                  },
                                );
                              },
                              text: 'Report an Issue',
                              buttonType: ButtonTypeEnum.textButton,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: mainProvider.bottomPadding),
                    ],
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
