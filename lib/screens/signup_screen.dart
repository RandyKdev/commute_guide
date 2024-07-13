import 'dart:io';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_size_enum.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/signup_provider.dart';
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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late ChangeNotifierProvider<SignupProvider> changeSignupProvider;
  @override
  void initState() {
    super.initState();

    changeSignupProvider = ChangeNotifierProvider(
      (ref) {
        return SignupProvider(
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
    final signupProvider = ref.watch(changeSignupProvider);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Enter your details below'),
                const SizedBox(height: 30),
                TextFieldWidget(
                  labelText: 'Name',
                  hintText: 'Enter name',
                  controller: signupProvider.nameController,
                  keyboardType: TextInputType.name,
                  validator: (val) => signupProvider.validateName(),
                  focusNode: signupProvider.nameFocusNode,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  labelText: 'Email',
                  hintText: 'Enter email',
                  controller: signupProvider.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => signupProvider.validateEmail(),
                  focusNode: signupProvider.emailFocusNode,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  labelText: 'Password',
                  hintText: '.......................',
                  obscureText: signupProvider.obscurePasswordText,
                  controller: signupProvider.passwordController,
                  keyboardType: TextInputType.text,
                  validator: (val) => signupProvider.validatePassword(),
                  focusNode: signupProvider.passwordFocusNode,
                  suffixIcon: IconButton(
                    icon: signupProvider.obscurePasswordText
                        ? const Icon(CupertinoIcons.eye_fill)
                        : const Icon(CupertinoIcons.eye_slash_fill),
                    onPressed: () {
                      signupProvider.obscurePasswordText =
                          !signupProvider.obscurePasswordText;
                    },
                    iconSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  labelText: 'Confirm Password',
                  hintText: '.......................',
                  obscureText: signupProvider.obscureConfirmPasswordText,
                  controller: signupProvider.confirmPasswordController,
                  keyboardType: TextInputType.text,
                  validator: (val) => signupProvider.validateConfirmPassword(),
                  focusNode: signupProvider.confirmPasswordFocusNode,
                  suffixIcon: IconButton(
                    icon: signupProvider.obscureConfirmPasswordText
                        ? const Icon(CupertinoIcons.eye_fill)
                        : const Icon(CupertinoIcons.eye_slash_fill),
                    onPressed: () {
                      signupProvider.obscureConfirmPasswordText =
                          !signupProvider.obscureConfirmPasswordText;
                    },
                    iconSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  onTap: () {
                    signupProvider.signUpWithEmailAndPassword();
                  },
                  text: 'Sign Up',
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
                    signupProvider.signupWithGoogle();
                  },
                  text: 'Continue with Google',
                  buttonType: ButtonTypeEnum.filledSecondary,
                  leading: SvgPicture.asset('assets/logos/google_logo.svg'),
                ),
                if (Platform.isIOS) ...[
                  const SizedBox(height: 20),
                  ButtonWidget(
                    onTap: () {
                      signupProvider.signupWithApple();
                    },
                    text: 'Continue with Apple',
                    buttonType: ButtonTypeEnum.filledSecondary,
                    leading: SvgPicture.asset(
                      'assets/logos/apple_logo.svg',
                      color: Colors.black,
                    ),
                  ),
                ],
                SizedBox(height: signupProvider.spaceBeforeSignup),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Have an account?"),
                    const SizedBox(width: 5),
                    ButtonWidget(
                      onTap: () {
                        signupProvider.navToLogin();
                      },
                      text: 'Login',
                      buttonType: ButtonTypeEnum.textButton,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
