import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/extensions/string_ext.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FavoriteEditableListTileWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final String? address;
  final PlaceTypeEnum placeTypeEnum;
  final Future<void> Function() onTap;
  final bool isEditing;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final int? index;
  final bool isAddStopScreen;

  const FavoriteEditableListTileWidget({
    super.key,
    required this.changeMainProvider,
    required this.onTap,
    required this.address,
    required this.placeTypeEnum,
    this.isEditing = false,
    required this.onShare,
    required this.onDelete,
    required this.index,
    this.isAddStopScreen = false,
  });

  @override
  ConsumerState<FavoriteEditableListTileWidget> createState() =>
      _FavoriteEditableListTileWidgetState();
}

class _FavoriteEditableListTileWidgetState
    extends ConsumerState<FavoriteEditableListTileWidget>
    with SingleTickerProviderStateMixin {
  bool loading = false;
  bool showDone = false;
  late SlidableController slidableController;

  @override
  void initState() {
    super.initState();
    slidableController = SlidableController(this);
  }

  @override
  void dispose() {
    slidableController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FavoriteEditableListTileWidget oldWidget) {
    if (oldWidget.isEditing != widget.isEditing ||
        oldWidget.index != widget.index) {
      slidableController.close();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(widget.changeMainProvider);
    final address = widget.address ??
        '${widget.placeTypeEnum.name.getWordsCapitalized}, Add your ${widget.placeTypeEnum.name.getWordsCapitalized}';

    final child = Container(
      width: double.maxFinite,
      color: widget.isAddStopScreen ? null : Colors.white,
      child: Slidable(
        key: widget.key,
        controller: slidableController,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 2,
              onPressed: (ctx) async {
                widget.onShare();
                await slidableController.close();
              },
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              label: 'Share',
            ),
            SlidableAction(
              flex: 2,
              onPressed: (ctx) async {
                widget.onDelete();
                await slidableController.close();
              },
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              label: 'Delete',
            ),
          ],
        ),
        enabled: widget.isEditing,
        groupTag: 'favorites',
        closeOnScroll: true,
        child: GestureDetector(
          onTap: widget.isEditing ? null : widget.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isAddStopScreen ? 0 : 20,
              vertical: 15,
            ),
            color: widget.isAddStopScreen ? null : Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isEditing && widget.address != null) ...[
                  GestureDetector(
                    onTap: () async {
                      await slidableController.openEndActionPane();
                    },
                    child: const Icon(
                      CupertinoIcons.minus_circle_fill,
                      size: 22,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.05),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    widget.placeTypeEnum == PlaceTypeEnum.home
                        ? CupertinoIcons.house_fill
                        : widget.placeTypeEnum == PlaceTypeEnum.work
                            ? CupertinoIcons.briefcase_fill
                            : CupertinoIcons.star_fill,
                    color: AppColors.primaryBlue,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.substring(0, address.indexOf(',')),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        address.substring(address.indexOf(',') + 2),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.isEditing &&
                    widget.placeTypeEnum == PlaceTypeEnum.other) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      CupertinoIcons.line_horizontal_3,
                      color: Colors.grey.withOpacity(.2),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (widget.placeTypeEnum != PlaceTypeEnum.other || widget.index == null) {
      return child;
    }

    return Column(
      children: [
        Divider(
          color: Colors.grey.withOpacity(.05),
          height: 1,
          indent: 20,
          thickness: 1,
        ),
        ReorderableDragStartListener(
          index: widget.index!,
          enabled: widget.isEditing,
          child: child,
        ),
      ],
    );
  }
}
