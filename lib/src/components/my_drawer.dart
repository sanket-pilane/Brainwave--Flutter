import 'package:brainwave/src/features/code/presentation/pages/code_page.dart';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  List<ScreenHiddenDrawer> _pages = [];

  final baseStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.w500);

  final selectedStyle = TextStyle(
      color: Colors.grey.shade300, fontWeight: FontWeight.bold, fontSize: 16);

  @override
  void initState() {
    super.initState();
    _pages = [
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: "Chat", baseStyle: baseStyle, selectedStyle: selectedStyle),
          CodePage()),
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
    return HiddenDrawerMenu(
      isTitleCentered: true,
      backgroundColorAppBar: Colors.transparent,
      actionsAppBar: [
        IconButton(
            // ignore: avoid_print
            onPressed: () => print("New Chat"),
            icon: Icon(
              Icons.chat,
              size: 20,
            ))
      ],
      backgroundColorMenu: Colors.deepPurple.shade300,
      screens: _pages,
      initPositionSelected: 0,
    );
  }
}
