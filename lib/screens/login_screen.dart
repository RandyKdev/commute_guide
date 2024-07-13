import 'dart:io';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_size_enum.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/login_provider.dart';
import 'package:commute_guide/repositories/auth_repository.dart';
import 'package:commute_guide/repositories/message_repository.dart';
import 'package:commute_guide/repositories/user_repository.dart';
import 'package:commute_guide/screens/base_screen.dart';
import 'package:commute_guide/services/auth_service.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/services/size_config_service.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/text_form_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late ChangeNotifierProvider<LoginProvider> changeLoginProvider;
  @override
  void initState() {
    super.initState();

    changeLoginProvider = ChangeNotifierProvider(
      (ref) {
        return LoginProvider(
          authRepository: ref.read(authRepository),
          authService: ref.read(authService),
          globalProvider: ref.read(globalProvider),
          navigationService: ref.read(navigationService),
          messageRepository: ref.read(messageRepository),
          userRepository: ref.read(userRepository),
          sizeConfigService: ref.read(sizeConfigService),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = ref.watch(changeLoginProvider);
    return BaseScreen(build: ({required EdgeInsets padding}) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/logos/icon.png',
                height: 30,
                width: 30,
              ),
              const SizedBox(width: 10),
              const Text(
                'Commute Guide',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: padding.left,
              right: padding.right,
              bottom: padding.bottom,
            ),
            child: Form(
              key: loginProvider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign in to your\nAccount',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Enter your email and password to log in'),
                  const SizedBox(height: 30),
                  TextFieldWidget(
                    labelText: 'Email',
                    hintText: 'Enter email',
                    controller: loginProvider.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => loginProvider.validateEmail(),
                    focusNode: loginProvider.emailFocusNode,
                  ),
                  const SizedBox(height: 20),
                  TextFieldWidget(
                    labelText: 'Password',
                    hintText: '.......................',
                    obscureText: loginProvider.obscureText,
                    controller: loginProvider.passwordController,
                    keyboardType: TextInputType.text,
                    validator: (val) => loginProvider.validatePassword(),
                    focusNode: loginProvider.passwordFocusNode,
                    suffixIcon: IconButton(
                      icon: loginProvider.obscureText
                          ? const Icon(CupertinoIcons.eye_fill)
                          : const Icon(CupertinoIcons.eye_slash_fill),
                      onPressed: () {
                        loginProvider.obscureText = !loginProvider.obscureText;
                      },
                      iconSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ButtonWidget(
                      text: 'Forgot Password?',
                      onTap: () {
                        loginProvider.forgotPassword();
                      },
                      buttonType: ButtonTypeEnum.textButton,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ButtonWidget(
                    onTap: () {
                      loginProvider.logInWithEmailAndPassword();
                    },
                    text: 'Log In',
                    buttonType: ButtonTypeEnum.filledPrimary,
                    buttonSize: ButtonSizeEnum.fullWidth,
                  ),
                  const SizedBox(height: 40),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.grey,
                          endIndent: 25,
                          height: 1,
                          thickness: 1,
                        ),
                      ),
                      Text('Or'),
                      Expanded(
                        child: Divider(
                          color: AppColors.grey,
                          indent: 25,
                          height: 1,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ButtonWidget(
                    onTap: () {
                      loginProvider.loginWithGoogle();
                    },
                    text: 'Continue with Google',
                    buttonType: ButtonTypeEnum.filledSecondary,
                    leading: SvgPicture.asset('assets/logos/google_logo.svg'),
                  ),
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 20),
                    ButtonWidget(
                      onTap: () {
                        loginProvider.loginWithApple();
                      },
                      text: 'Continue with Apple',
                      buttonType: ButtonTypeEnum.filledSecondary,
                      leading: SvgPicture.asset(
                        'assets/logos/apple_logo.svg',
                        color: Colors.black,
                      ),
                    ),
                  ],
                  SizedBox(height: loginProvider.spaceBeforeSignup),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      const SizedBox(width: 5),
                      ButtonWidget(
                        onTap: () {
                          loginProvider.navToSignup();
                        },
                        text: 'Sign Up',
                        buttonType: ButtonTypeEnum.textButton,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
