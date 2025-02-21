import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:brainwave/src/features/chat/bloc/chat_bloc.dart';
import 'package:brainwave/src/features/image/domain/model/image_model.dart';
import 'package:brainwave/src/features/image/domain/repo/image_repo.dart';
import 'package:meta/meta.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  ImageBloc() : super(ImageSuccessState(messages: [])) {
    on<ImageGeneratedEvent>(imageGenerateEvent);
  }

  List<ImageModel> messages = [];
  FutureOr<void> imageGenerateEvent(
    ImageGeneratedEvent event,
    Emitter<ImageState> emit,
  ) async {
    messages.add(ImageModel(role: "user", text: event.prompt));
    emit(ImageSuccessState(messages: List.from(messages)));

    try {
      String outputUrl = await ImageRepo.imageGenerateRepo(event.prompt);

      if (outputUrl.isNotEmpty) {
        messages.add(ImageModel(role: "model", text: outputUrl));
      }

      emit(ImageSuccessState(messages: List.from(messages)));
    } catch (e) {
      log(e.toString());
      emit(ImageSuccessState(
          messages:
              List.from(messages))); // Emit last known state in case of failure
    }
  }
}
