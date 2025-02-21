import 'package:brainwave/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_states.dart';
import 'package:brainwave/src/features/authentication/presentation/cubits/auth_cubits.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _profileImage;
  TextEditingController _nameController = TextEditingController(text: "User");
  bool _isEditing = false;

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  String _extractNameFromEmail(String email) {
    final username = email.split('@').first;
    return username.replaceAll(RegExp(r'\d'), ''); // Remove numbers
  }

  void signOut() async {
    final authCubit = context.read<AuthCubits>();

    authCubit.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: BlocBuilder<AuthCubits, AuthStates>(
            builder: (context, state) {
              String email = "";
              if (state is Authenticated) {
                email = state.user.email;
                String name = state.user.email;
                if (_nameController.text == "User") {
                  _nameController.text = name;
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Lottie.asset(userProfile,
                                    width: 100, height: 100),
                              ),
                      ),
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isEditing
                          ? Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Text(
                              _nameController.text,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit,
                            color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(email,
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: signOut,
                    icon: Icon(Icons.logout),
                    label: Text("Sign Out"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
