import 'package:equatable/equatable.dart';

class PersonalInfoState extends Equatable {
  final String gender;   // 'male' | 'female'
  final double weight;   // kg
  final double height;   // cm
  final int yearOfBirth;

  const PersonalInfoState({
    this.gender      = 'male',
    this.weight      = 70.0,
    this.height      = 170.0,
    this.yearOfBirth = 2000,
  });

  int get age {
    final now = DateTime.now();
    return now.year - yearOfBirth;
  }

  /// BMI = weight(kg) / (height(m))²
  double get bmi {
    if (height <= 0) return 0;
    final hm = height / 100;
    return weight / (hm * hm);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25)   return 'Normal';
    if (b < 30)   return 'Overweight';
    return 'Obese';
  }

  PersonalInfoState copyWith({
    String? gender,
    double? weight,
    double? height,
    int?    yearOfBirth,
  }) =>
      PersonalInfoState(
        gender:      gender      ?? this.gender,
        weight:      weight      ?? this.weight,
        height:      height      ?? this.height,
        yearOfBirth: yearOfBirth ?? this.yearOfBirth,
      );

  @override
  List<Object> get props => [gender, weight, height, yearOfBirth];
}