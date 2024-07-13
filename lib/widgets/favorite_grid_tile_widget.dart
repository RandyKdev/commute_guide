import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteGridTileWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final String? address;
  final PlaceTypeEnum placeTypeEnum;
  final Future<void> Function() onTap;
  final bool isAdd;
  const FavoriteGridTileWidget({
    super.key,
    required this.changeMainProvider,
    required this.onTap,
    required this.address,
    required this.placeTypeEnum,
    this.isAdd = false,
  });

  @override
  ConsumerState<FavoriteGridTileWidget> createState() =>
      _FavoriteGridTileWidgetState();
}

class _FavoriteGridTileWidgetState
    extends ConsumerState<FavoriteGridTileWidget> {
  bool loading = false;
  bool showDone = false;
  @override
  Widget build(BuildContext context) {
    ref.watch(widget.changeMainProvider);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        width: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.05),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                widget.isAdd
                    ? CupertinoIcons.add
                    : widget.placeTypeEnum == PlaceTypeEnum.home
                        ? CupertinoIcons.house_fill
                        : widget.placeTypeEnum == PlaceTypeEnum.work
                            ? CupertinoIcons.briefcase_fill
                            : CupertinoIcons.star_fill,
                color: AppColors.primaryBlue,
                size: 35,
              ),
            ),
            const SizedBox(height: 5),
            if (widget.address != null)
              Text(
                widget.address!,
                style: const TextStyle(
                  fontSize: 12,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              )
            else ...[
              Text(
                widget.placeTypeEnum == PlaceTypeEnum.home ? 'Home' : 'Work',
                style: const TextStyle(
                  fontSize: 12,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Add',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              )
            ]
          ],
        ),
      ),
    );
  }
}
