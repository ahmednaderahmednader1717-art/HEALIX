import 'package:flutter/material.dart';

class Nutrient {
  final String name; // اسم العنصر: Protein, Carbs, Fats
  final double value; // النسبة 0.0 - 1.0
  final Color color; // اللون الخاص بالحلقة

  Nutrient({required this.name, required this.value, required this.color});

  static List<Nutrient> nutrients = [
    Nutrient(
      name: "Calories",
      value: .75,
      color: const Color.fromARGB(161, 190, 37, 37),
    ),
    Nutrient(
      name: "Protein",
      value: 0.25,
      color: const Color.fromARGB(146, 50, 168, 54),
    ),
    Nutrient(
      name: "Carbs",
      value: 1.0,
      color: const Color.fromARGB(160, 42, 127, 196),
    ),
    Nutrient(
      name: "Fats",
      value: 0.50,
      color: const Color.fromARGB(145, 215, 145, 41),
    ),
  ];
}
