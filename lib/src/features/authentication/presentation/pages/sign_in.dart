import 'package:brainwave/src/components/my_button.dart';
import 'package:brainwave/src/components/my_textfields.dart';
import 'package:brainwave/src/components/text_tile.dart';
import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/features/authentication/presentation/pages/sign_up.dart';
import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topLeft,
            colors: [
              Color.fromARGB(255, 14, 17, 29),
              Color.fromARGB(255, 32, 37, 58),
              Color.fromARGB(255, 49, 48, 48),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              "Login to your Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Login with",
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                TextTile(imagePath: kGoogleLogo, title: "Google"),
                SizedBox(
                  width: 10,
                ),
                TextTile(imagePath: kFacebookLogo, title: "Facebook"),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            MyTextfield(
                hintText: "Email", icon: Icons.mail, obscureText: false),
            MyTextfield(
                hintText: "Password", icon: Icons.lock, obscureText: true),
            const SizedBox(
              height: 10,
            ),
            MyButton(
              title: "Login",
              onTap: () {},
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have account?",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
