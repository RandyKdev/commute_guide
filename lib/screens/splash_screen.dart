import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Spacer(),
          Image.asset(
            'assets/logos/icon.png',
            height: MediaQuery.sizeOf(context).height / 2,
            width: MediaQuery.sizeOf(context).width / 2,
          ),
          const SizedBox(height: 50),
          const CupertinoActivityIndicator(),
          const Spacer(),
        ],
      ),
    ));
  }
}
