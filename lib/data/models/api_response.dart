// /// Authentication Response
// class AuthResponse {
//   final String token;
//   final String? refreshToken;
//   final UserData user;

//   AuthResponse({
//     required this.token,
//     this.refreshToken,
//     required this.user,
//   });

//   /// Parse from JSON
//   /// Expected format:
//   /// {
//   ///   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
//   ///   "refreshToken": "optional_refresh_token",
//   ///   "user": {
//   ///     "id": "123",
//   ///     "name": "Ahmed",
//   ///     "email": "ahmed@test.com",
//   ///     "profileImage": "url"
//   ///   }
//   /// }
//   factory AuthResponse.fromJson(Map<String, dynamic> json) {
//     return AuthResponse(
//       token: json['token'] as String,
//       refreshToken: json['refreshToken'] as String?,
//       user: UserData.fromJson(json['user'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'token': token,
//       'refreshToken': refreshToken,
//       'user': user.toJson(),
//     };
//   }
// }

// /// User Data
// class UserData {
//   final String id;
//   final String name;
//   final String email;
//   final String? profileImage;

//   UserData({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.profileImage,
//   });

//   factory UserData.fromJson(Map<String, dynamic> json) {
//     return UserData(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       email: json['email'] as String,
//       profileImage: json['profileImage'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'profileImage': profileImage,
//     };
//   }
// }

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

  /// Parse from JSON - handles multiple response formats:
  ///
  /// Format 1 (flat):
  /// { "token": "...", "user": { ... } }
  ///
  /// Format 2 (nested in data):
  /// { "data": { "token": "...", "user": { ... } } }
  ///
  /// Format 3 (token + user separate):
  /// { "accessToken": "...", "user": { ... } }
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Unwrap "data" if present
    final Map<String, dynamic> payload =
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;

    // Support both "token" and "accessToken"
    final token = (payload['token'] ?? payload['accessToken']) as String?;
    if (token == null) {
      throw FormatException(
          'AuthResponse: missing token field. Keys found: ${payload.keys.toList()}');
    }

    // Support both "user" object and flat user fields
    UserData user;
    if (payload['user'] is Map<String, dynamic>) {
      user = UserData.fromJson(payload['user'] as Map<String, dynamic>);
    } else {
      // Flat format - user fields are at root level
      user = UserData.fromJson(payload);
    }

    return AuthResponse(
      token: token,
      refreshToken: payload['refreshToken'] as String?,
      user: user,
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

  /// Parse from JSON - handles multiple id field names:
  /// "id", "_id", "userId"
  factory UserData.fromJson(Map<String, dynamic> json) {
    // Support "_id" (MongoDB) or "id" or "userId"
    final id = (json['id'] ?? json['_id'] ?? json['userId'])?.toString();
    if (id == null) {
      throw FormatException(
          'UserData: missing id field. Keys found: ${json.keys.toList()}');
    }

    return UserData(
      id: id,
      name: (json['name'] ?? json['username'] ?? '') as String,
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