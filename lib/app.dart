import 'package:brainwave/home_page.dart';
import 'package:brainwave/src/components/my_drawer.dart';
import 'package:brainwave/src/constants/colors.dart';
import 'package:brainwave/src/features/authentication/data/firebase_auth_repo.dart';
import 'package:brainwave/src/features/authentication/domain/repo/auth_repo.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_states.dart';
import 'package:brainwave/src/features/on_boarding/presentation/on_onboarding.dart';
// Import your home page
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
        theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: AppBarTheme(backgroundColor: AppColors.searchBar)),
        home: BlocListener<AuthCubits, AuthStates>(
          listener: (context, state) {
            if (state is Authenticated) {
              // Navigate to the HomePage when authenticated
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MyDrawer()),
              );
            } else if (state is UnAuthenticated) {
              // Navigate back to OnOnboarding if unauthenticated
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => OnOnboarding()),
              );
            }
          },
          child: OnOnboarding(), // Initial page
        ),
      ),
    );
  }
}
