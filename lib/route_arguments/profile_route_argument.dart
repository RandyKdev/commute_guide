import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/route_arguments/main_route_argument.dart';

class ProfileRouteArgument extends MainRouteArgument {
  final AppUser user;

  const ProfileRouteArgument({
    required this.user,
  });
}
