import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cheatsheets.freezed.dart';

@UseRowClass(Cheatsheet)
class Cheatsheets extends Table {
  IntColumn get id => integer().autoIncrement()();

  // We use a special UUID instead of the actual ID since it would make it more
  // complicated to attempt to use the ID with a Frozen class.
  TextColumn get name => text()();
  IntColumn get secondaryLevel =>
      integer().check(secondaryLevel.isBetweenValues(1, 4))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  BoolColumn get comingSoon => boolean().withDefault(const Constant(false))();
}

// Custom row class for the Notes table

@freezed
class Cheatsheet with _$Cheatsheet {
  const factory Cheatsheet(
      {required String name,
      required int secondaryLevel,
      @Default(false) bool starred,
      @Default(false) bool comingSoon}) = _Cheatsheet;
}

const cheatSheetList = [
  Cheatsheet(name: "Numbers and Their Operations Part 1", secondaryLevel: 1),
  Cheatsheet(name: "Numbers and Their Operations Part 2", secondaryLevel: 1),
  Cheatsheet(name: "Percentages", secondaryLevel: 1),
  Cheatsheet(
      name: "Basic Algebra and Algebraic Manipulation", secondaryLevel: 1),
  Cheatsheet(name: "Linear Equations and Inequalities", secondaryLevel: 1),
  Cheatsheet(name: "Functions and Linear Graphs", secondaryLevel: 1),
  Cheatsheet(name: "Basic Geometry", secondaryLevel: 1),
  Cheatsheet(name: "Polygons", secondaryLevel: 1),
  Cheatsheet(name: "Geometrical Construction", secondaryLevel: 1),
  Cheatsheet(name: "Number Sequences", secondaryLevel: 1),
  Cheatsheet(name: "Similarity and Congruence Part 1", secondaryLevel: 2),
  Cheatsheet(name: "Similarity and Congruence Part 2", secondaryLevel: 2),
  Cheatsheet(name: "Ratio and Proportion", secondaryLevel: 2),
  Cheatsheet(name: "Direct and Inverse Proportions", secondaryLevel: 2),
  Cheatsheet(name: "Pythagoras Theorem", secondaryLevel: 2),
  Cheatsheet(name: "Trigonometric Ratios", secondaryLevel: 2),
  Cheatsheet(name: "Indices", secondaryLevel: 3),
  Cheatsheet(name: "Surds", secondaryLevel: 3),
  Cheatsheet(name: "Functions and Graphs", secondaryLevel: 3),
  Cheatsheet(
      name: "Quadratic Functions, Equations, and Inequalities",
      secondaryLevel: 3),
  Cheatsheet(name: "Coordinate Geometry", secondaryLevel: 3),
  Cheatsheet(name: "Exponentials and Logarithms", secondaryLevel: 3),
  Cheatsheet(name: "Further Coordinate Geometry", secondaryLevel: 3),
  Cheatsheet(name: "Linear Law", secondaryLevel: 3),
  Cheatsheet(name: "Geometrical Properties of Circles", secondaryLevel: 3),
  Cheatsheet(name: "Polynomials and Partial Fractions", secondaryLevel: 3),
  Cheatsheet(name: "Coming Soon...", secondaryLevel: 4, comingSoon: true)
];
