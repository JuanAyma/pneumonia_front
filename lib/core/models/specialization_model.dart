import 'package:flutter/material.dart';

enum SymptomFieldType { slider, toggle }

class SymptomFieldDef {
  final String id;
  final String labelKey;
  final SymptomFieldType type;
  final double? min;
  final double? max;
  final int? divisions;
  final double? defaultSliderValue;
  final bool? defaultToggleValue;

  const SymptomFieldDef({
    required this.id,
    required this.labelKey,
    required this.type,
    this.min,
    this.max,
    this.divisions,
    this.defaultSliderValue,
    this.defaultToggleValue,
  });
}

class SpecializationModel {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;
  final String modelPath;
  final String labelsPath;
  final bool isAvailable;
  final List<SymptomFieldDef> symptomFields;

  const SpecializationModel({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.modelPath,
    required this.labelsPath,
    this.isAvailable = true,
    required this.symptomFields,
  });
}
