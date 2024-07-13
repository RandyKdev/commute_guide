import 'package:commute_guide/providers/base_provider.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key, required this.build});

  final Scaffold Function({required EdgeInsets padding}) build;

  @override
  ConsumerState<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends ConsumerState<BaseScreen> {
  late ChangeNotifierProvider<BaseProvider> changeBaseProvider;
  @override
  void initState() {
    super.initState();

    changeBaseProvider = ChangeNotifierProvider(
      (ref) {
        return BaseProvider(
          navigationService: ref.read(navigationService),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseProvider = ref.watch(changeBaseProvider);
    MediaQuery.viewInsetsOf(context);
    MediaQuery.viewPaddingOf(context);
    return widget.build(padding: baseProvider.padding);
  }
}
