import 'package:brainwave/src/components/my_drawer.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_states.dart';
import 'package:brainwave/src/features/authentication/presentation/pages/auth_page.dart';
import 'package:brainwave/src/features/on_boarding/presentation/on_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubits, AuthStates>(
      builder: (context, state) {
        if (state is Authenticated) {
          return MyDrawer(); // Authenticated UI
        } else if (state is UnAuthenticated) {
          return AuthPage(); // Login page
        } else {
          return OnOnboarding(); // Fallback page
        }
      },
    );
  }
}
