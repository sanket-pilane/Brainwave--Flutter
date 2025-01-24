import 'package:brainwave/src/constants/colors.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';
import 'package:brainwave/src/features/chat/presentation/pages/chat_page.dart';
import 'package:brainwave/src/features/code/presentation/pages/code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  List<ScreenHiddenDrawer> _pages = [];

  final baseStyle =
      TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500);

  final selectedStyle = TextStyle(
      color: Colors.grey.shade300, fontWeight: FontWeight.bold, fontSize: 16);

  @override
  void initState() {
    super.initState();
    _pages = [
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: "Chat", baseStyle: baseStyle, selectedStyle: selectedStyle),
          ChatPage()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: "Video",
              baseStyle: baseStyle,
              selectedStyle: selectedStyle),
          CodePage()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: "Audio",
              baseStyle: baseStyle,
              selectedStyle: selectedStyle),
          CodePage()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: "Image",
              baseStyle: baseStyle,
              selectedStyle: selectedStyle),
          CodePage()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: "Code", baseStyle: baseStyle, selectedStyle: selectedStyle),
          CodePage()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    void signOut() async {
      final authCubit = context.read<AuthCubits>();

      authCubit.logout();
    }

    return HiddenDrawerMenu(
      isTitleCentered: true,
      elevationAppBar: 0,
      styleAutoTittleName: TextStyle(color: Colors.white),
      leadingAppBar: Icon(
        Icons.menu,
        color: Colors.white,
      ),
      backgroundColorAppBar: AppColors.background,
      actionsAppBar: [
        IconButton(
            // ignore: avoid_print
            onPressed: () => signOut(),
            icon: Icon(
              Icons.chat,
              size: 20,
              color: Colors.white,
            ))
      ],
      backgroundColorMenu: AppColors.cardColor,
      screens: _pages,
      initPositionSelected: 0,
    );
  }
}
