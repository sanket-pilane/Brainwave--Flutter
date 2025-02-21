// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ImageModel {
  final String role;
  final String text;

  ImageModel({required this.role, required this.text});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'text': text,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      role: map['role'] as String,
      text: map['text'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageModel.fromJson(String source) =>
      ImageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
