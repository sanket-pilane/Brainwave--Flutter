import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:brainwave/src/features/video/domain/model/video_model.dart';
import 'package:brainwave/src/features/video/domain/repo/video_repo.dart';
import 'package:meta/meta.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(VideoSuccessState(messages: [])) {
    on<VideoGeneratedEvent>(VideoGenerateEvent);
  }

  List<VideoModel> messages = [];
  FutureOr<void> VideoGenerateEvent(
    VideoGeneratedEvent event,
    Emitter<VideoState> emit,
  ) async {
    messages.add(VideoModel(role: "user", text: event.prompt));
    emit(VideoSuccessState(messages: List.from(messages)));

    try {
      String outputUrl = await VideoRepo.VideoGenerateRepo(event.prompt);
      print(outputUrl);
      if (outputUrl.isNotEmpty) {
        messages.add(VideoModel(role: "model", text: outputUrl));
      }

      emit(VideoSuccessState(messages: List.from(messages)));
    } catch (e) {
      log(e.toString());
      emit(VideoSuccessState(
          messages:
              List.from(messages))); // Emit last known state in case of failure
    }
  }

  Future<void> delayFor5Seconds() async {
    await Future.delayed(Duration(seconds: 5));
  }
}
