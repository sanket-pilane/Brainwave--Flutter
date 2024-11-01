import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final TextEditingController controller;
  const MyTextfield(
      {super.key,
      required this.hintText,
      required this.icon,
      required this.obscureText,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            icon,
            color: Colors.white,
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.6),
              ),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}
