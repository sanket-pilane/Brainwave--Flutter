part of 'audio_bloc.dart';

@immutable
sealed class AudioState {}

final class AudioInitial extends AudioState {}

class AudioLoadingState extends AudioState {}

class AudioSuccessState extends AudioState {
  final List<AudioModel> messages;

  AudioSuccessState({required this.messages});
}
