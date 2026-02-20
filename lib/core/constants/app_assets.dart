class AppAssets {
  AppAssets._();

  // Images
  static const String logo = 'assets/images/logo.png';
  static const String vitalMetricsLogo = 'assets/images/vital_metrics_logo.png';
  
  // Gender images
  static const String maleImage = 'assets/images/male.png';
  static const String femaleImage = 'assets/images/female.png';
  
  // Social auth logos
  static const String googleLogo = 'assets/images/google_logo.png';
  static const String facebookLogo = 'assets/images/face_book_logo.png';
  
  // Goal images
  static const String gainWeightImage = 'assets/images/gain_image.jpg';
  static const String loseWeightImage = 'assets/images/lose_image.jpg';
  
  // Onboarding images
  static const String thanksImage = 'assets/images/thanks.png';
  
  // Helper method to get gender image
  static String getGenderImage(String gender) {
    return gender.toLowerCase() == 'male' ? maleImage : femaleImage;
  }
  
  // Helper method to get goal image
  static String getGoalImage(String goalType) {
    return goalType.toLowerCase().contains('gain') 
        ? gainWeightImage 
        : loseWeightImage;
  }
}