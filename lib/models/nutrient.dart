import 'package:flutter/material.dart';

class Nutrient {
  final String name; // اسم العنصر: Protein, Carbs, Fats
  final double value; // النسبة 0.0 - 1.0
  final Color color; // اللون الخاص بالحلقة

  Nutrient({required this.name, required this.value, required this.color});

  static List<Nutrient> nutrients = [
    Nutrient(name: "Calories", value: .75, color: const Color.fromARGB(255, 245, 44, 44)),
    Nutrient(name: "Protein", value: 0.25, color: Colors.green),
    Nutrient(name: "Carbs", value: 1.0, color: Colors.blue),
    Nutrient(name: "Fats", value: 0.50, color: Colors.orange),
  ];

}
