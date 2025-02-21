part of 'image_bloc.dart';

@immutable
sealed class ImageState {}

final class ImageInitial extends ImageState {}

class ImageLoadingState extends ImageState {}

class ImageSuccessState extends ImageState {
  final List<ImageModel> messages;

  ImageSuccessState({required this.messages});
}
