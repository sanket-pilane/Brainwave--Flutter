import 'package:brainwave/src/components/my_button.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void signOut() async {
      final authCubit = context.read<AuthCubits>();

      authCubit.logout();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Brainwave"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Hello Moto"),
            MyButton(title: "Logout", onTap: signOut)
          ],
        ),
      ),
    );
  }
}
  