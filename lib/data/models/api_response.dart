class AuthResponse {
  final String token;
  final String? refreshToken;
  final UserData user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload =
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;

    // ✅ access_token أو token أو accessToken
    final token = _safeStr(payload, 'access_token')
        ?? _safeStr(payload, 'token')
        ?? _safeStr(payload, 'accessToken');

    if (token == null) {
      throw FormatException(
          'AuthResponse: missing token. Keys: ${payload.keys.toList()}');
    }

    UserData user;
    if (payload['user'] is Map<String, dynamic>) {
      user = UserData.fromJson(payload['user'] as Map<String, dynamic>);
    } else {
      user = UserData.fromJson(payload);
    }

    return AuthResponse(
      token: token,
      // ✅ refresh_token أو refreshToken
      refreshToken: _safeStr(payload, 'refresh_token')
          ?? _safeStr(payload, 'refreshToken'),
      user: user,
    );
  }

  static String? _safeStr(Map<String, dynamic> map, String key) {
    final val = map[key];
    if (val is String) return val;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'access_token':  token,
        'refresh_token': refreshToken,
        'user':          user.toJson(),
      };
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final bool? onboardingComplete;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.onboardingComplete,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    // ✅ user_id أو id أو _id أو userId
    final id = (json['user_id'] ?? json['id'] ?? json['_id'] ?? json['userId'])
        ?.toString();

    if (id == null) {
      throw FormatException(
          'UserData: missing id. Keys: ${json.keys.toList()}');
    }

    return UserData(
      id:    id,
      name:  _safeStr(json, 'name') ?? _safeStr(json, 'username') ?? '',
      email: _safeStr(json, 'email') ?? '',
      profileImage: json['profileImage'] is String
          ? json['profileImage'] as String
          : null,
      onboardingComplete: json['onboardingComplete'] is bool
          ? json['onboardingComplete'] as bool
          : null,
    );
  }

  static String? _safeStr(Map<String, dynamic> map, String key) {
    final val = map[key];
    if (val is String) return val;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'user_id':            id,
        'name':               name,
        'email':              email,
        'profileImage':       profileImage,
        'onboardingComplete': onboardingComplete,
      };
}