import 'package:brainwave/home_page.dart';
import 'package:brainwave/src/features/authentication/presentation/pages/sign_up.dart';
import 'package:brainwave/src/features/on_boarding/presentation/intro_page1.dart';
import 'package:brainwave/src/features/on_boarding/presentation/intro_page2.dart';
import 'package:brainwave/src/features/on_boarding/presentation/intro_page3.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnOnboarding extends StatefulWidget {
  const OnOnboarding({super.key});

  @override
  State<OnOnboarding> createState() => _OnOnboardingState();
}

class _OnOnboardingState extends State<OnOnboarding> {
  PageController _controller = PageController();

  bool onLastPage = false;
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
                index = index;
              });
            },
            controller: _controller,
            children: const [IntroPage1(), IntroPage2(), IntroPage3()],
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  axisDirection: Axis.horizontal,
                  effect: ColorTransitionEffect(
                      dotColor: Colors.white,
                      activeDotColor: Colors.grey.shade700,
                      dotWidth: 10,
                      dotHeight: 10),
                ),
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUp(),
                              ));
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
