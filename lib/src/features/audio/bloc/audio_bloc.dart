import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:brainwave/src/features/audio/domain/model/audio_model.dart';
import 'package:brainwave/src/features/audio/domain/repo/audio_repo.dart';

import 'package:meta/meta.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  AudioBloc() : super(AudioSuccessState(messages: [])) {
    on<AudioGeneratedEvent>(AudioGenerateEvent);
  }

  List<AudioModel> messages = [];
  FutureOr<void> AudioGenerateEvent(
    AudioGeneratedEvent event,
    Emitter<AudioState> emit,
  ) async {
    messages.add(AudioModel(role: "user", text: event.prompt));
    emit(AudioSuccessState(messages: List.from(messages)));

    try {
      String outputUrl = await AudioRepo.AudioGenerateRepo(event.prompt);
      print(outputUrl);
      if (outputUrl.isNotEmpty) {
        messages.add(AudioModel(role: "model", text: outputUrl));
      }

      emit(AudioSuccessState(messages: List.from(messages)));
    } catch (e) {
      log(e.toString());
      emit(AudioSuccessState(
          messages:
              List.from(messages))); // Emit last known state in case of failure
    }
  }

  Future<void> delayFor5Seconds() async {
    await Future.delayed(Duration(seconds: 5));
  }
}
