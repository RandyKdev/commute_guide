import 'package:commute_guide/providers/base_provider.dart';
import 'package:intl/intl.dart';

class HomeProvider extends BaseProvider {
  bool _loading = true;
  bool get loading => _loading;

  int _index = 0;
  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  late NumberFormat _numberFormat;

  HomeProvider({
    required super.navigationService,
  }) {
    init();
  }

  void init() async {
    _numberFormat = NumberFormat.compact();
    _loading = false;
    notifyListeners();
  }

  String getShortNumbers(num? value) {
    value ??= 0;
    return _numberFormat.format(value);
  }
}
