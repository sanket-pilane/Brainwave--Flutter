import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Lottie.asset(loadingAnimation2),
      ),
    );
  }
}
