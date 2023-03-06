import 'package:flutter/foundation.dart';

class Employee {
  final String matricula;
  final String h01;
  final String h02;
  final String h03;
  final String h04;
  final String h05;
  final String h06;
  final String h07;
  final String h08;
  final String h09;
  final String h10;
  final String h11;
  final String h12;
  final String h13;
  final String h14;
  final String h15;
  final String h16;
  final String h17;
  final String h18;

  Employee({
    this.matricula,
    this.h01,
    this.h02,
    this.h03,
    this.h04,
    this.h05,
    this.h06,
    this.h07,
    this.h08,
    this.h09,
    this.h10,
    this.h11,
    this.h12,
    this.h13,
    this.h14,
    this.h15,
    this.h16,
    this.h17,
    this.h18,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      matricula: json['matricula'] as String,
      h01: json['h01'] as String,
      h02: json['h02'] as String,
      h03: json['h03'] as String,
      h04: json['h04'] as String,
      h05: json['h05'] as String,
      h06: json['h06'] as String,
      h07: json['h07'] as String,
      h08: json['h08'] as String,
      h09: json['h09'] as String,
      h10: json['h10'] as String,
      h11: json['h11'] as String,
      h12: json['h12'] as String,
      h13: json['h13'] as String,
      h14: json['h14'] as String,
      h15: json['h15'] as String,
      h16: json['h16'] as String,
      h17: json['h17'] as String,
      h18: json['h18'] as String,
    );
  }
}
