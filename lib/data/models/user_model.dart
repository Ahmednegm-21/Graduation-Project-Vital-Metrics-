class UserModel {
  final String? id;
  final String  name;
  final String  email;
  final String? profileImage;
  final DateTime? createdAt;
  final bool?   onboardingComplete;
  final bool    isAdmin;          

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.createdAt,
    this.onboardingComplete,
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:                 json['id']                 as String?,
      name:               json['name']               as String,
      email:              json['email']              as String,
      profileImage:       json['profileImage']       as String?,
      createdAt:          json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      onboardingComplete: json['onboardingComplete'] as bool?,
      isAdmin:            json['is_admin']           as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'name':               name,
    'email':              email,
    'profileImage':       profileImage,
    'createdAt':          createdAt?.toIso8601String(),
    'onboardingComplete': onboardingComplete,
    'is_admin':           isAdmin,
  };

  UserModel copyWith({
    String?   id,
    String?   name,
    String?   email,
    String?   profileImage,
    DateTime? createdAt,
    bool?     onboardingComplete,
    bool?     isAdmin,
  }) => UserModel(
    id:                 id                 ?? this.id,
    name:               name               ?? this.name,
    email:              email              ?? this.email,
    profileImage:       profileImage       ?? this.profileImage,
    createdAt:          createdAt          ?? this.createdAt,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    isAdmin:            isAdmin            ?? this.isAdmin,
  );
}