part of 'audio_bloc.dart';

@immutable
sealed class AudioEvent {}

class AudioGeneratedEvent extends AudioEvent {
  final String prompt;

  AudioGeneratedEvent({required this.prompt});
}
