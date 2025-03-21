part of 'video_bloc.dart';

@immutable
sealed class VideoEvent {}

class VideoGeneratedEvent extends VideoEvent {
  final String prompt;

  VideoGeneratedEvent({required this.prompt});
}
