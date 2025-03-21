// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AudioModel {
  final String role;
  final String text;

  AudioModel({required this.role, required this.text});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'text': text,
    };
  }

  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      role: map['role'] as String,
      text: map['text'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioModel.fromJson(String source) =>
      AudioModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
