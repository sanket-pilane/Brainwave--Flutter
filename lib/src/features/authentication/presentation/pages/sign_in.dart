import 'package:brainwave/src/components/my_button.dart';
import 'package:brainwave/src/components/my_textfields.dart';
import 'package:brainwave/src/components/text_tile.dart';
import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignIn extends StatefulWidget {
  final void Function()? onTap;
  const SignIn({super.key, required this.onTap});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    final String email = emailController.text;
    final String pass = passwordController.text;

    final authCubit = context.read<AuthCubits>();

    if (email.isNotEmpty && pass.isNotEmpty) {
      authCubit.login(email, pass);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please Enter both email and Password")));
    }
  }

  void googleAuth() async {
    final authCubit = context.read<AuthCubits>();

    authCubit.googleAuth();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
              children: [
                GestureDetector(
                    onTap: googleAuth,
                    child: TextTile(imagePath: kGoogleLogo, title: "Google")),
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
              hintText: "Email",
              icon: Icons.mail,
              obscureText: false,
              controller: emailController,
            ),
            MyTextfield(
              hintText: "Password",
              icon: Icons.lock,
              obscureText: true,
              controller: passwordController,
            ),
            const SizedBox(
              height: 10,
            ),
            MyButton(
              title: "Login",
              onTap: login,
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
                    onTap: widget.onTap,
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
