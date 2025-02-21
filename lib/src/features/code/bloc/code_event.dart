// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'code_bloc.dart';

@immutable
sealed class CodeEvent {}

class CodeGenerateNewTextMessageEvent extends CodeEvent {
  final String prompt;
  CodeGenerateNewTextMessageEvent({
    required this.prompt,
  });
}
