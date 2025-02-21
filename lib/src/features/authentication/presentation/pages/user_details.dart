import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Bloc State
class UserDetailsState {
  final File? profileImage;
  final String username;
  final String role;

  UserDetailsState(
      {this.profileImage, this.username = '', this.role = 'Student'});
}

// Bloc Event
abstract class UserDetailsEvent {}

class UpdateProfileImage extends UserDetailsEvent {
  final File image;
  UpdateProfileImage(this.image);
}

class UpdateUsername extends UserDetailsEvent {
  final String username;
  UpdateUsername(this.username);
}

class UpdateRole extends UserDetailsEvent {
  final String role;
  UpdateRole(this.role);
}

// Bloc
class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  UserDetailsBloc() : super(UserDetailsState());

  @override
  Stream<UserDetailsState> mapEventToState(UserDetailsEvent event) async* {
    if (event is UpdateProfileImage) {
      yield UserDetailsState(
          profileImage: event.image,
          username: state.username,
          role: state.role);
    } else if (event is UpdateUsername) {
      yield UserDetailsState(
          profileImage: state.profileImage,
          username: event.username,
          role: state.role);
    } else if (event is UpdateRole) {
      yield UserDetailsState(
          profileImage: state.profileImage,
          username: state.username,
          role: event.role);
    }
  }
}

class UserDetailsPage extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserDetailsBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text('User Details')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocBuilder<UserDetailsBloc, UserDetailsState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () async {
                      final pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        context
                            .read<UserDetailsBloc>()
                            .add(UpdateProfileImage(File(pickedFile.path)));
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: state.profileImage != null
                          ? FileImage(state.profileImage!)
                          : null,
                      child: state.profileImage == null
                          ? Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Username', border: OutlineInputBorder()),
                onChanged: (value) =>
                    context.read<UserDetailsBloc>().add(UpdateUsername(value)),
              ),
              SizedBox(height: 20),
              BlocBuilder<UserDetailsBloc, UserDetailsState>(
                builder: (context, state) {
                  return ToggleButtons(
                    children: [
                      Text('Student'),
                      Text('Developer'),
                      Text('Designer'),
                      Text('Freelancer')
                    ],
                    isSelected: [
                      state.role == 'Student',
                      state.role == 'Developer',
                      state.role == 'Designer',
                      state.role == 'Freelancer'
                    ],
                    onPressed: (index) {
                      List<String> roles = [
                        'Student',
                        'Developer',
                        'Designer',
                        'Freelancer'
                      ];
                      context
                          .read<UserDetailsBloc>()
                          .add(UpdateRole(roles[index]));
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final state = context.read<UserDetailsBloc>().state;
                  print(
                      'Username: ${state.username}, Role: ${state.role}, Image: ${state.profileImage?.path}');
                },
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
