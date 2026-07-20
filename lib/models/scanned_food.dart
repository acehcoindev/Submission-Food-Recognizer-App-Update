import 'dart:convert';

class ScannedFood {
  final String id;
  final String name;
  final double confidence;
  final String imagePath;
  final String origin;
  final String halalStatus;
  final String halalReason;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  final List<String> recipeIngredients;
  final String recipeInstructions;
  final DateTime dateTime;

  ScannedFood({
    required this.id,
    required this.name,
    required this.confidence,
    required this.imagePath,
    required this.origin,
    required this.halalStatus,
    required this.halalReason,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.recipeIngredients,
    required this.recipeInstructions,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'confidence': confidence,
      'imagePath': imagePath,
      'origin': origin,
      'halalStatus': halalStatus,
      'halalReason': halalReason,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      'recipeIngredients': recipeIngredients,
      'recipeInstructions': recipeInstructions,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory ScannedFood.fromMap(Map<String, dynamic> map) {
    return ScannedFood(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath'] ?? '',
      origin: map['origin'] ?? '',
      halalStatus: map['halalStatus'] ?? 'Unknown',
      halalReason: map['halalReason'] ?? '',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      recipeIngredients: List<String>.from(map['recipeIngredients'] ?? []),
      recipeInstructions: map['recipeInstructions'] ?? '',
      dateTime: DateTime.parse(map['dateTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory ScannedFood.fromJson(String source) => ScannedFood.fromMap(json.decode(source));
}
