import 'dart:async';
import 'dart:developer';

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

  List<ChatModel> messages = []; // Store all chat messages

  FutureOr<void> chatGenerateNewTextMessageEvent(
    ChatGenerateNewTextMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Add user message
    messages.add(
      ChatModel(role: "user", parts: [ChatPartModel(text: event.prompt)]),
    );
    emit(ChatSuccesState(messages: List.from(messages))); // Emit updated state

    try {
      // Generate a response using the chat repository
      String generatedString = await ChatRepo.ChatGenerateRepo(messages);

      if (generatedString.isNotEmpty) {
        // Add model-generated message
        messages.add(
          ChatModel(
              role: "model", parts: [ChatPartModel(text: generatedString)]),
        );
        // log("After adding model message: ${messages.map((m) => m.role + ': ' + m.parts.first.text).toList()}");
        emit(ChatSuccesState(
            messages: List.from(messages))); // Emit updated state
      }
    } catch (e) {
      // Handle errors (optional)
      log(e.toString());
    }
  }
}
