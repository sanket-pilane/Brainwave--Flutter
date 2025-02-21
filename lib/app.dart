import 'package:brainwave/authnavigator.dart';

import 'package:brainwave/src/constants/colors.dart';
import 'package:brainwave/src/features/authentication/data/firebase_auth_repo.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
// Import your home page
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: AppBarTheme(backgroundColor: AppColors.searchBar),
          ),
          home: AuthNavigator()),
    );
  }
}
