import 'package:commute_guide/constants/routes.dart';
import 'package:commute_guide/helpers/show_info_dialog_helper.dart';
import 'package:commute_guide/helpers/show_loader_dialog_helper.dart';
import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/providers/base_provider.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/repositories/auth_repository.dart';
import 'package:commute_guide/repositories/message_repository.dart';
import 'package:commute_guide/repositories/user_repository.dart';
import 'package:commute_guide/services/auth_service.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/services/size_config_service.dart';
import 'package:commute_guide/widgets/snackbar_widget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginProvider extends BaseProvider {
  final AuthRepository _authRepository;
  final AuthService _authService;
  final NavigationService _navigationService;
  final MessageRepository _messageRepository;
  final UserRepository _userRepository;
  final SizeConfigService _sizeConfigService;

  LoginProvider({
    required AuthRepository authRepository,
    required AuthService authService,
    required GlobalProvider globalProvider,
    required super.navigationService,
    required MessageRepository messageRepository,
    required UserRepository userRepository,
    required SizeConfigService sizeConfigService,
  })  : _authRepository = authRepository,
        _authService = authService,
        _navigationService = navigationService,
        _messageRepository = messageRepository,
        _userRepository = userRepository,
        _sizeConfigService = sizeConfigService {
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    _sizeConfigService.init(_navigationService.currentContext);
  }

  late GlobalKey<FormState> formKey;

  late TextEditingController emailController;
  late TextEditingController passwordController;

  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;

  bool _obscureText = true;

  bool get obscureText => _obscureText;

  set obscureText(bool val) {
    _obscureText = val;
    notifyListeners();
  }

  double get spaceBeforeSignup {
    if (_sizeConfigService.screenHeight < 800) {
      return 30;
    }

    return _sizeConfigService.screenHeight * (80 / 932);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  // Stream<AppUser?> get user => firebaseAuth.userChanges().;

  Future<void> _navigatoToRespScreen(AppUser? user) async {
    if (user != null) {
      final fcmToken = await _messageRepository.initNotifications();
      if (fcmToken == null) return;
      final fcmTokens = user.fcmTokens ?? [];
      final newUser = user.copy(
          fcmTokens: fcmTokens
            ..removeWhere((element) => element == fcmToken)
            ..add(fcmToken));
      await _userRepository.updateUser(newUser);
      return;
    }

    _navigationService.pop();
  }

  Future<void> navToSignup() async {
    _navigationService.popAllAndPushNamed(Routes.signup);
  }

  Future<void> forgotPassword() async {
    final context = _navigationService.currentContext;
    if (!EmailValidator.validate(emailController.text.trim())) {
      CommuteSnackBarError(
        title: 'Input a valid email',
        context: _navigationService.currentContext,
      );
      return;
    }

    showLoaderDialoHelper(context);

    await _authRepository.forgotPassword(emailController.text.trim());
    _navigationService.pop();
    if (!context.mounted) return;
    showInfoDialogHelper(
      context: context,
      onTap: () {
        _navigationService.pop();
      },
      btnText: 'OK',
      childText:
          'A password reset mail has been sent to ${emailController.text.trim()}',
    );
  }

  Future<AppUser?> logInWithEmailAndPassword() async {
    formKey.currentState?.validate();
    if (validateEmail() != null || validatePassword() != null) {
      return null;
    }

    showLoaderDialoHelper(_navigationService.currentContext);

    try {
      final user = await _authRepository.logInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await _navigatoToRespScreen(user);
      return user;
    } catch (err) {
      // throw Failure(code: err.code, message: err.message!);
    }
    await _navigatoToRespScreen(null);
    return null;
  }

  Future<AppUser?> loginWithGoogle() async {
    showLoaderDialoHelper(_navigationService.currentContext);

    try {
      final user = await _authService.signInWithGoogle();
      await _navigatoToRespScreen(user);
      return user;
    } catch (e) {
      _navigationService.pop();
      return null;
    }
  }

  Future<AppUser?> loginWithApple() async {
    showLoaderDialoHelper(_navigationService.currentContext);

    try {
      final user = await _authService.signInWithApple();
      await _navigatoToRespScreen(user);
      return user;
    } catch (e) {
      _navigationService.pop();
      return null;
    }
  }

  String? validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      return "Please enter your email";
    }

    if (!EmailValidator.validate(email)) {
      return "Please enter a valid email";
    }

    return null;
  }

  String? validatePassword() {
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      return "Please enter a password";
    }

    return null;
  }
}
