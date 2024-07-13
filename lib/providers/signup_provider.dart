import 'package:commute_guide/constants/routes.dart';
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
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SignupProvider extends BaseProvider {
  final AuthRepository _authRepository;
  final AuthService _authService;
  final NavigationService _navigationService;
  final MessageRepository _messageRepository;
  final UserRepository _userRepository;
  final SizeConfigService _sizeConfigService;

  SignupProvider({
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
    nameController = TextEditingController();
    confirmPasswordController = TextEditingController();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    _sizeConfigService.init(_navigationService.currentContext);
  }

  late GlobalKey<FormState> formKey;

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;

  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode confirmPasswordFocusNode;
  late FocusNode nameFocusNode;

  bool _obscurePasswordText = true;

  bool get obscurePasswordText => _obscurePasswordText;

  set obscurePasswordText(bool val) {
    _obscurePasswordText = val;
    notifyListeners();
  }

  bool _obscureConfirmPasswordText = true;

  bool get obscureConfirmPasswordText => _obscureConfirmPasswordText;

  set obscureConfirmPasswordText(bool val) {
    _obscureConfirmPasswordText = val;
    notifyListeners();
  }

  double get spaceBeforeSignup {
    if (_sizeConfigService.screenHeight < 950) {
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
    nameController.dispose();
    nameFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // Stream<AppUser?> get user => firebaseAuth.userChanges().;

  Future<void> _navigatoToRespScreen(AppUser? user) async {
    if (user != null) {
      final fcmToken = await _messageRepository.initNotifications();
      if (fcmToken == null) return;
      final fcmTokens = [...?user.fcmTokens];
      final newUser = user.copy(
        fcmTokens: fcmTokens
          ..removeWhere((element) => element == fcmToken)
          ..add(fcmToken),
        name: nameController.text.trim(),
      );
      await _userRepository.updateUser(newUser);
      return;
    }

    _navigationService.pop();
  }

  Future<AppUser?> signUpWithEmailAndPassword() async {
    formKey.currentState?.validate();
    if (validateEmail() != null || validatePassword() != null) {
      return null;
    }
    showLoaderDialoHelper(_navigationService.currentContext);

    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _navigatoToRespScreen(user);

      return user;
    } catch (err) {
      debugPrint(err.toString());
      // throw Failure(code: err.code, message: err.message!);
    }
    return null;
  }

  Future<AppUser?> signupWithGoogle() async {
    showLoaderDialoHelper(_navigationService.currentContext);
    try {
      final user = await _authService.signInWithGoogle();
      await _navigatoToRespScreen(user);

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<AppUser?> signupWithApple() async {
    showLoaderDialoHelper(_navigationService.currentContext);
    try {
      final user = await _authService.signInWithApple();
      await _navigatoToRespScreen(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> navToLogin() async {
    _navigationService.popAllAndPushNamed(Routes.login);
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

    if (password.length < 9) {
      return 'Password should have more than 9 chars';
    }

    return null;
  }

  String? validateName() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      return "Please enter your full name";
    }

    if (name.length < 5 || !name.contains(' ')) {
      return 'Please enter your full name';
    }

    return null;
  }

  String? validateConfirmPassword() {
    final confirmPassword = confirmPasswordController.text.trim();
    final password = passwordController.text.trim();

    if (confirmPassword != password) {
      return "Passwords do not match";
    }

    return null;
  }
}
