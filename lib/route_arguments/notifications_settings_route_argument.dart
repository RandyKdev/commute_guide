import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/route_arguments/main_route_argument.dart';

class NotificationsSettingsRouteArgument extends MainRouteArgument {
  final AppUser user;

  const NotificationsSettingsRouteArgument({
    required this.user,
  });
}
