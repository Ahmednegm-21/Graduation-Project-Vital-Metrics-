class OnboardingConfig {
  OnboardingConfig._();

  // Progress steps
  static const Map<String, double> progressSteps = {
    'gender': 0.20,
    'height': 0.40,
    'weight': 0.60,
    'age': 0.90,
  };

  // Height configuration
  static const Map<String, double> heightConfig = {
    'min': 120,
    'max': 220,
    'default': 170,
  };
  static const int heightDivisions = 100;

  // Weight configuration
  static const Map<String, double> weightConfig = {
    'min': 30,
    'max': 150,
    'default': 70,
  };
  static const int weightDivisions = 120;

  // Age configuration
  static const Map<String, double> ageConfig = {
    'min': 10,
    'max': 100,
    'default': 25,
  };
  static const int ageDivisions = 90;

  // Preview dimensions ratios
  static const double previewWidthRatio = 0.92;
  static const double previewHeightRatioGender = 0.40;
  static const double previewHeightRatioOther = 0.48;


  static double getProgressValue(String step) {
    return progressSteps[step] ?? 0.0;
  }
}