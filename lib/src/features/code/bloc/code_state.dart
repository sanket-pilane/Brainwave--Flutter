// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'code_bloc.dart';

@immutable
sealed class CodeState {}

final class CodeInitial extends CodeState {}

class CodeSuccesState extends CodeState {
  final List<CodeModel> messages;
  CodeSuccesState({
    required this.messages,
  });
}
