import 'package:quiz/model/category.dart';

class Quesion {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Quesion({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Quesion.fromMap(Map<String, dynamic> map) {
    return Quesion(
      text: map['text'] ?? "",
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  Quesion copyWith({
    String? text,
    List<String>? options,
    int? correctOptionIndex,
  }) {
    return Quesion(
      text: text ?? this.text,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
    );
  }
}
