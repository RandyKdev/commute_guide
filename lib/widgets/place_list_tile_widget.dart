import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaceListTileWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final CommutePlace place;
  final bool showAddIcon;
  final bool showStarIcon;
  final Future<void> Function() onTap;
  final bool showSearchIcon;
  final bool addRightPadding;
  const PlaceListTileWidget({
    super.key,
    required this.showSearchIcon,
    required this.changeMainProvider,
    required this.place,
    required this.showAddIcon,
    required this.onTap,
    this.addRightPadding = true,
    required this.showStarIcon,
  });

  @override
  ConsumerState<PlaceListTileWidget> createState() =>
      _PlaceListTileWidgetState();
}

class _PlaceListTileWidgetState extends ConsumerState<PlaceListTileWidget> {
  bool loading = false;
  bool showDone = false;
  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    return InkWell(
      splashColor: Colors.white,
      focusColor: Colors.white,
      hoverColor: Colors.white,
      highlightColor: Colors.white,
      onTap: () async {
        if (loading || showDone) return;
        if (widget.showAddIcon) {
          setState(() {
            loading = true;
            showDone = false;
          });
        }

        await widget.onTap();
        if (widget.showAddIcon) {
          setState(() {
            loading = false;
            showDone = true;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 15,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.showStarIcon
                    ? Colors.grey.withOpacity(.05)
                    : Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(5),
              child: Icon(
                widget.showStarIcon
                    ? CupertinoIcons.star_fill
                    : widget.showSearchIcon
                        ? CupertinoIcons.search
                        : CupertinoIcons.map_pin,
                color:
                    widget.showStarIcon ? AppColors.primaryBlue : Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place.address.substring(
                      0,
                      widget.place.address.indexOf(','),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.place.address.substring(
                      widget.place.address.indexOf(',') + 2,
                    ),
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
            if (loading)
              const SizedBox(width: 50, child: CupertinoActivityIndicator())
            else if (widget.showAddIcon && !showDone)
              const SizedBox(
                width: 50,
                child: Icon(
                  CupertinoIcons.add,
                  color: AppColors.primaryBlue,
                ),
              )
            else if (showDone)
              const SizedBox(
                width: 50,
                child: Icon(
                  CupertinoIcons.checkmark_alt,
                  color: AppColors.primaryBlue,
                ),
              ),
            SizedBox(
              width: widget.addRightPadding
                  ? mainProvider.rightPadding
                  : mainProvider.rightOnlyPadding,
            ),
          ],
        ),
      ),
    );
  }
}
