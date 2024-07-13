import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/helpers/show_info_dialog_helper.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/repositories/user_repository.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/text_form_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddIssueBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  final PlaceTypeEnum placeType;
  const AddIssueBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
    this.placeType = PlaceTypeEnum.other,
  });

  @override
  ConsumerState<AddIssueBottomSheetWidget> createState() =>
      _AddIssueBottomSheetWidgetState();
}

class _AddIssueBottomSheetWidgetState
    extends ConsumerState<AddIssueBottomSheetWidget> {
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
  final descriptionController = TextEditingController();
  IssueEnum? issueType;
  List<File> images = [];
  bool uploading = false;

  bool get canUpload =>
      issueType != null &&
      images.isNotEmpty &&
      descriptionController.text.isNotEmpty;

  @override
  void dispose() {
    timer.cancel();
    descriptionController.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 10),
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
                              SizedBox(
                                width: 50,
                                child: ButtonWidget(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: 'Cancel',
                                  buttonType: ButtonTypeEnum.textButton,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Report Issue',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (uploading)
                                const SizedBox(
                                  width: 50,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: CupertinoActivityIndicator()),
                                )
                              else
                                SizedBox(
                                  width: 50,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: ButtonWidget(
                                      onTap: canUpload
                                          ? () async {
                                              setState(() {
                                                uploading = true;
                                              });

                                              if (await ref
                                                  .read(userRepository)
                                                  .shouldSendEmailVerification()) {
                                                await showInfoDialogHelper(
                                                  childText:
                                                      'You have to verify your email before uploading issues. Check your email, a verification email has been sent',
                                                  title: 'Verify Email',
                                                  btnText: 'Ok',
                                                  context: context,
                                                  barrierDismissible: true,
                                                  onTap: () {
                                                    ref
                                                        .read(navigationService)
                                                        .pop();
                                                  },
                                                );
                                                setState(() {
                                                  uploading = false;
                                                });
                                                return;
                                              }
                                              final issue = await mainProvider
                                                  .uploadIssue(
                                                images: images,
                                                description:
                                                    descriptionController.text,
                                                issue: issueType!,
                                                userId: ref
                                                        .read(globalProvider)
                                                        .user
                                                        ?.id ??
                                                    '',
                                              );
                                              setState(() {
                                                uploading = false;
                                              });
                                              Navigator.of(context).pop(issue);
                                            }
                                          : () {},
                                      text: 'Done',
                                      textStyle: TextStyle(
                                        color: canUpload
                                            ? AppColors.primaryBlue
                                            : Colors.grey,
                                      ),
                                      buttonType: ButtonTypeEnum.textButton,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 200,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: mainProvider.leftPadding),
                                      ...images.map((image) {
                                        return Row(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: double.maxFinite,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.grey
                                                          .withOpacity(.05),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: Image.file(
                                                      image,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        CupertinoIcons
                                                            .xmark_circle_fill,
                                                        size: 30,
                                                      ),
                                                      onPressed: () {
                                                        images.remove(image);
                                                        setState(() {});
                                                      },
                                                      enableFeedback: true,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                          ],
                                        );
                                      }),
                                      GestureDetector(
                                        onTap: () async {
                                          final imagePicker = ImagePicker();
                                          final image =
                                              await imagePicker.pickImage(
                                            source: ImageSource.camera,
                                            preferredCameraDevice:
                                                CameraDevice.rear,
                                          );

                                          if (image == null) return;
                                          images.add(File(image.path));
                                          setState(() {});
                                        },
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color:
                                                  Colors.grey.withOpacity(.05),
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.add_circled_solid,
                                              color: AppColors.primaryBlue,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: mainProvider.rightPadding),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.only(
                                  left: mainProvider.leftPadding,
                                  right: mainProvider.rightPadding,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Type',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 15,
                                      children: [
                                        ...IssueEnum.values.map((issue) {
                                          return ChoiceChip.elevated(
                                            label: Text(
                                              issue == IssueEnum.accidents
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
                                                                      IssueEnum
                                                                          .event
                                                                  ? 'Event'
                                                                  : 'Issue',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onSelected: (val) {
                                              setState(() {
                                                issueType = issue;
                                              });
                                            },
                                            selected: issueType == issue,
                                            selectedColor: const Color.fromARGB(
                                                255, 9, 68, 186),
                                            checkmarkColor: Colors.white,
                                            backgroundColor: Colors.grey,
                                            elevation: 0,
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: mainProvider.leftPadding,
                                  right: mainProvider.rightPadding,
                                ),
                                child: TextFieldWidget(
                                  labelText: 'Description',
                                  controller: descriptionController,
                                  minLines: 5,
                                  multiLines: 5,
                                  onChanged: (v) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
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
