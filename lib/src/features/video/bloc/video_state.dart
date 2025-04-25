import 'package:brainwave/src/features/video/domain/model/video_model.dart';
import 'package:flutter/material.dart';

@immutable
sealed class VideoState {}

final class VideoInitial extends VideoState {}

class VideoLoadingState extends VideoState {}

class VideoSuccessState extends VideoState {
  final List<VideoModel> messages;

  VideoSuccessState({required this.messages});
}
