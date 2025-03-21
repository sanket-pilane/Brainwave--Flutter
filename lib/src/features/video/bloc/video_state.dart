part of 'video_bloc.dart';

@immutable
sealed class VideoState {}

final class VideoInitial extends VideoState {}

class VideoLoadingState extends VideoState {}

class VideoSuccessState extends VideoState {
  final List<VideoModel> messages;

  VideoSuccessState({required this.messages});
}
