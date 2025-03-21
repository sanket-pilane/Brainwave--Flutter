// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class VideoModel {
  final String role;
  final String text;

  VideoModel({required this.role, required this.text});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'text': text,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      role: map['role'] as String,
      text: map['text'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoModel.fromJson(String source) =>
      VideoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
