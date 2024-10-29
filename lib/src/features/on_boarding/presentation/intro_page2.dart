import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/constants/colors.dart';
import 'package:brainwave/src/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSecondPrimaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              onBoardingTitle2,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              onBoardingSub2,
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 140, child: Lottie.asset(musicGeneration)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 200, child: Lottie.asset(videoGeneration)),
                      SizedBox(width: 160, child: Lottie.asset(textGeneration)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
