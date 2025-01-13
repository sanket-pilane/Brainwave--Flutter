// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

class ChatSuccesState extends ChatState {
  final List<ChatModel> messages;
  ChatSuccesState({
    required this.messages,
  });
}
