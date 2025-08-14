import 'package:quiz/model/quesion.dart';

class Quiz {
  final String id;
  final String title;
  final String categoryId;
  final int timeLimet;
  final List<Quesion> quisions;
  final DateTime? createdAt;
  final DateTime? updatesdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.timeLimet,
    required this.quisions,
    this.createdAt,
    this.updatesdAt,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id: id ?? "",
      title: map['title'] ?? "",
      categoryId: map['categoryId'] ?? "",
      timeLimet: map['timeLimit'] ?? 0,
      quisions: ((map['quisions'] ?? []) as List)
          .map((e) => Quesion.fromMap(e))
          .toList(),
      createdAt: map['createdAt']?.toData(),
      updatesdAt: map['updatedAt']?.toData(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimet,
      'quisions': quisions,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatesdAt ?? DateTime.now(),
    };
  }

  Quiz copyWith({
    String? title,
    String? categoryId,
    int? timeLimit,
    List<Quesion>? quisions,
  }) {
    return Quiz(
      id: id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timeLimet: timeLimet ?? this.timeLimet,
      quisions: quisions ?? this.quisions,
      createdAt: createdAt,
      updatesdAt: DateTime.now(),
    );
  }
}
