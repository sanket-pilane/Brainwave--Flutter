import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/constants/colors.dart';
import 'package:brainwave/src/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kVioletColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            onBoardingTitle3,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            onBoardingSub3,
            style: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
          Lottie.asset(chatbot1),
        ],
      ),
    );
  }
}
