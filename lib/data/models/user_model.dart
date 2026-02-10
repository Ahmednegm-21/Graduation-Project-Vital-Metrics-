class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.createdAt,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}