import 'package:brainwave/src/components/loading.dart';
import 'package:brainwave/src/components/my_drawer.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_states.dart';
import 'package:brainwave/src/features/authentication/presentation/pages/auth_page.dart';
import 'package:brainwave/src/features/on_boarding/presentation/on_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  bool? isFirstTime; // Nullable to handle the loading state

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('isFirstTime') ?? true;
    debugPrint("Is first time: $firstTime"); // Debugging log

    if (mounted) {
      setState(() {
        isFirstTime = firstTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstTime == null) {
      // While checking SharedPreferences, show a loading indicator
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isFirstTime!) {
      // Show onboarding only on the first launch
      return OnOnboarding(
        onFinish: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstTime', false);
          if (mounted) {
            setState(() {
              isFirstTime = false;
            });
          }
        },
      );
    }
    return BlocBuilder<AuthCubits, AuthStates>(
      builder: (context, state) {
        if (state is Authenticated) {
          return MyDrawer(); // Authenticated UI
        } else if (state is UnAuthenticated) {
          return AuthPage(); // Login page
        } else if (state is AuthLoading) {
          return Center(
            child: LoadingPage(), // Show loading indicator
          );
          // Fallback page
        } else {
          return LoadingPage();
        }
      },
    );
  }
}
