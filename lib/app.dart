import 'package:brainwave/home_page.dart';
import 'package:brainwave/src/components/loading.dart';
import 'package:brainwave/src/components/my_drawer.dart';
import 'package:brainwave/src/features/authentication/data/firebase_auth_repo.dart';
import 'package:brainwave/src/features/authentication/domain/repo/auth_repo.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_states.dart';
import 'package:brainwave/src/features/authentication/presentation/pages/auth_page.dart';
import 'package:brainwave/src/features/code/presentation/pages/code_page.dart';
import 'package:brainwave/src/features/on_boarding/presentation/on_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final authRepo = FirebaseAuthRepo();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AuthCubits(authRepo: authRepo)..checkAuth(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Brainwave",
            home: OnOnboarding()));
  }
}
