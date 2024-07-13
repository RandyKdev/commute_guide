import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/models/issue.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class IssueListTileWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final CommuteIssue issue;
  final Future<void> Function() onTap;
  final VoidCallback? onDelete;
  final int? index;
  final bool isEditing;

  const IssueListTileWidget({
    super.key,
    required this.changeMainProvider,
    required this.onTap,
    required this.onDelete,
    required this.index,
    required this.issue,
    required this.isEditing,
  });

  @override
  ConsumerState<IssueListTileWidget> createState() =>
      _IssueListTileWidgetState();
}

class _IssueListTileWidgetState extends ConsumerState<IssueListTileWidget>
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
  void didUpdateWidget(covariant IssueListTileWidget oldWidget) {
    if (oldWidget.isEditing != widget.isEditing ||
        oldWidget.index != widget.index) {
      slidableController.close();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(widget.changeMainProvider);

    final child = Container(
      width: double.maxFinite,
      color: Colors.white,
      child: Slidable(
        key: widget.key,
        controller: slidableController,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              flex: 2,
              onPressed: (ctx) async {
                widget.onDelete?.call();
                await slidableController.close();
              },
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              label: 'Delete',
            ),
          ],
        ),
        enabled: widget.isEditing,
        groupTag: 'issues',
        closeOnScroll: true,
        child: GestureDetector(
          onTap: widget.isEditing ? null : widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isEditing) ...[
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
                    widget.issue.issue == IssueEnum.accidents
                        ? Icons.car_crash
                        : widget.issue.issue == IssueEnum.naturalDisasters
                            ? CupertinoIcons.flame_fill
                            : widget.issue.issue == IssueEnum.obstructions
                                ? Icons.waterfall_chart
                                : widget.issue.issue == IssueEnum.construction
                                    ? Icons.waterfall_chart
                                    : widget.issue.issue == IssueEnum.event
                                        ? Icons.waterfall_chart
                                        : Icons.report,
                    color: AppColors.primaryBlue,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.issue.issue == IssueEnum.accidents ? 'Accident' : widget.issue.issue == IssueEnum.naturalDisasters ? 'Natural Disaster' : widget.issue.issue == IssueEnum.obstructions ? 'Obstruction' : 'Issue'}${widget.issue.address == null ? '' : ' at ${widget.issue.address!.substring(
                                  0,
                                  widget.issue.address!.indexOf(','),
                                )}'}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              // maxLines: 1,
                              textAlign: TextAlign.left,
                              // overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm d/M')
                                .format(widget.issue.createdAt),
                          ),
                        ],
                      ),
                      Text(
                        widget.issue.description,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                        // maxLines: 1,
                        textAlign: TextAlign.left,
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return child;
  }
}
