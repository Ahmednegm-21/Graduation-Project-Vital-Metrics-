/// Authentication Response
class AuthResponse {
  final String token;
  final String? refreshToken;
  final UserData user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  /// Parse from JSON
  /// Expected format:
  /// {
  ///   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///   "refreshToken": "optional_refresh_token",
  ///   "user": {
  ///     "id": "123",
  ///     "name": "Ahmed",
  ///     "email": "ahmed@test.com",
  ///     "profileImage": "url"
  ///   }
  /// }
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

/// User Data
class UserData {
  final String id;
  final String name;
  final String email;
  final String? profileImage;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }
}