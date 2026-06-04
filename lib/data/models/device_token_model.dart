// lib/data/models/device_token_model.dart

class DeviceTokenModel {
  final int?    tokenId;
  final String  token;
  final String  platform;    // 'ios' | 'android' | 'web'
  final String  deviceName;
  final bool    isActive;
  final String? createdAt;
  final String? updatedAt;
  final int?    userId;

  const DeviceTokenModel({
    this.tokenId,
    required this.token,
    required this.platform,
    required this.deviceName,
    this.isActive  = true,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) {
    return DeviceTokenModel(
      tokenId:    json['token_id'],
      token:      json['token']       ?? '',
      platform:   json['platform']    ?? '',
      deviceName: json['device_name'] ?? '',
      isActive:   json['is_active']   ?? true,
      createdAt:  json['created_at'],
      updatedAt:  json['updated_at'],
      userId:     json['user_id'],
    );
  }

  /// Body sent when registering a new token (POST)
  Map<String, dynamic> toRegisterJson() => {
    'token':       token,
    'platform':    platform,
    'device_name': deviceName,
  };

  Map<String, dynamic> toJson() => {
    if (tokenId   != null) 'token_id':    tokenId,
    'token':       token,
    'platform':    platform,
    'device_name': deviceName,
    'is_active':   isActive,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
    if (userId    != null) 'user_id':    userId,
  };

  DeviceTokenModel copyWith({
    int?    tokenId,
    String? token,
    String? platform,
    String? deviceName,
    bool?   isActive,
    int?    userId,
  }) =>
      DeviceTokenModel(
        tokenId:    tokenId    ?? this.tokenId,
        token:      token      ?? this.token,
        platform:   platform   ?? this.platform,
        deviceName: deviceName ?? this.deviceName,
        isActive:   isActive   ?? this.isActive,
        createdAt:  createdAt,
        updatedAt:  updatedAt,
        userId:     userId     ?? this.userId,
      );

  @override
  String toString() =>
      'DeviceTokenModel(tokenId: $tokenId, platform: $platform, '
      'deviceName: $deviceName, isActive: $isActive)';
}