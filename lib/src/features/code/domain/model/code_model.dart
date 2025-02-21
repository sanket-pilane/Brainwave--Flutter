import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CodeModel {
  final String role;
  final List<CodePartModel> parts;
  CodeModel({
    required this.role,
    required this.parts,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'parts': parts.map((x) => x.toMap()).toList(),
    };
  }

  factory CodeModel.fromMap(Map<String, dynamic> map) {
    return CodeModel(
      role: map['role'] as String,
      parts: List<CodePartModel>.from(
        (map['parts'] as List<int>).map<CodePartModel>(
          (x) => CodePartModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CodeModel.fromJson(String source) =>
      CodeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CodePartModel {
  final String text;
  CodePartModel({
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
    };
  }

  factory CodePartModel.fromMap(Map<String, dynamic> map) {
    return CodePartModel(
      text: map['text'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CodePartModel.fromJson(String source) =>
      CodePartModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
