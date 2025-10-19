import 'package:flutter/material.dart';

class Nutrient {
  final String name; // اسم العنصر: Protein, Carbs, Fats
  final double value; // النسبة 0.0 - 1.0
  final Color color; // اللون الخاص بالحلقة

  Nutrient({required this.name, required this.value, required this.color});

  static List<Nutrient> nutrients = [
    Nutrient(name: "Protein", value: 0.65, color: Colors.green),
    Nutrient(name: "Carbs", value: 0.90, color: Colors.blue),
    Nutrient(name: "Fats", value: 0.45, color: Colors.orange),
    Nutrient(name: "Calories", value: 0.78, color: const Color.fromARGB(255, 245, 44, 44)),
  ];

}
