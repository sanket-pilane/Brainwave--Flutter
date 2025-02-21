part of 'image_bloc.dart';

@immutable
sealed class ImageEvent {}

class ImageGeneratedEvent extends ImageEvent {
  final String prompt;

  ImageGeneratedEvent({required this.prompt});
}
