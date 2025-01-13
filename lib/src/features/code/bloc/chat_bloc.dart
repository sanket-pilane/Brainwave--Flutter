import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brainwave/src/features/code/domain/model/chat_model.dart';
import 'package:brainwave/src/features/code/domain/repos/chatrepo.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatSuccesState(messages: [])) {
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }
  List<ChatModel> messages = [];
  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event, Emitter<ChatState> emit) async {
    messages.add(
        ChatModel(role: "user", parts: [ChatPartModel(text: event.prompt)]));
    emit(ChatSuccesState(messages: messages));

    // await ChatRepo.ChatGenerateRepo(messages);
  }
}
