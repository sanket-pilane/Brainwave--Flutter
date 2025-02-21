import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:brainwave/src/features/code/domain/model/code_model.dart';
import 'package:brainwave/src/features/code/domain/repos/coderepo.dart';
import 'package:meta/meta.dart';

part 'code_event.dart';
part 'code_state.dart';

class CodeBloc extends Bloc<CodeEvent, CodeState> {
  CodeBloc() : super(CodeSuccesState(messages: [])) {
    on<CodeGenerateNewTextMessageEvent>(codeGenerateNewTextMessageEvent);
  }

  List<CodeModel> messages = []; // Store all Code messages

  FutureOr<void> codeGenerateNewTextMessageEvent(
    CodeGenerateNewTextMessageEvent event,
    Emitter<CodeState> emit,
  ) async {
    // Add user message
    messages.add(
      CodeModel(role: "user", parts: [
        CodePartModel(
          text: event.prompt,
        )
      ]),
    );
    emit(CodeSuccesState(messages: List.from(messages))); // Emit updated state

    try {
      // Generate a response using the Code repository
      String generatedString = await CodeRepo.CodeGenerateRepo(messages);

      if (generatedString.isNotEmpty) {
        // Clean the unwanted text from the response
        String cleanedString = _cleanGeneratedResponse(generatedString);

        // Add model-generated message
        messages.add(
          CodeModel(
            role: "model",
            parts: [CodePartModel(text: cleanedString)],
          ),
        );
        emit(CodeSuccesState(
            messages: List.from(messages))); // Emit updated state
      }
    } catch (e) {
      // Handle errors (optional)
      log(e.toString());
    }
  }

  /// Function to clean unwanted text from the generated response
  String _cleanGeneratedResponse(String response) {
    const unwantedText =
        "You are a code generator. You must answer only in markdown code snippets. Use code comments for explanations. ";
    return response.replaceAll(unwantedText, "").trim();
  }
}
