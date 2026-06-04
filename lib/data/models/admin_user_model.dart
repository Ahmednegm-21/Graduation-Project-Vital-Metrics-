class AdminUserModel {
  final int    userId;
  final String name;
  final String email;
  final String gender;
  final double height;
  final double weight;
  final bool   isAdmin;
  final bool   isVerified;
  final String? createdAt;

  const AdminUserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.height,
    required this.weight,
    required this.isAdmin,
    this.isVerified = false,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      userId:     (json['user_id']  as num?)?.toInt() ?? 0,
      name:       json['name']      as String? ?? '',
      email:      json['email']     as String? ?? '',
      gender:     json['gender']    as String? ?? 'male',
      height:     (json['height']   as num?)?.toDouble() ?? 0.0,
      weight:     (json['weight']   as num?)?.toDouble() ?? 0.0,
      isAdmin:    json['is_admin']  as bool?   ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt:  json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id':     userId,
    'name':        name,
    'email':       email,
    'gender':      gender,
    'height':      height,
    'weight':      weight,
    'is_admin':    isAdmin,
    'is_verified': isVerified,
    'created_at':  createdAt,
  };

  AdminUserModel copyWith({
    int?    userId,
    String? name,
    String? email,
    String? gender,
    double? height,
    double? weight,
    bool?   isAdmin,
    bool?   isVerified,
    String? createdAt,
  }) =>
      AdminUserModel(
        userId:     userId     ?? this.userId,
        name:       name       ?? this.name,
        email:      email      ?? this.email,
        gender:     gender     ?? this.gender,
        height:     height     ?? this.height,
        weight:     weight     ?? this.weight,
        isAdmin:    isAdmin    ?? this.isAdmin,
        isVerified: isVerified ?? this.isVerified,
        createdAt:  createdAt  ?? this.createdAt,
      );

  @override
  String toString() =>
      'AdminUserModel(userId: $userId, name: $name, '
      'email: $email, isAdmin: $isAdmin)';
}