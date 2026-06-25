export const AUTH_CONFIG = {
  SALT_ROUNDS: 12,
  ACCESS_TOKEN_EXPIRY: '7d',
  REFRESH_TOKEN_EXPIRY: '7d',
  MIN_PASSWORD_LENGTH: 8,
} as const;

export const AUTH_ERRORS = {
  INVALID_CREDENTIALS: 'Invalid credentials',
  EMAIL_EXISTS: 'User with this email already exists',
  USERNAME_EXISTS: 'Username is already taken',
  USER_NOT_FOUND: 'User not found',
  INVALID_TOKEN: 'Invalid token',
  TOKEN_EXPIRED: 'Token has expired',
  ACCESS_DENIED: 'Access denied',
  REFRESH_TOKEN_REQUIRED: 'Refresh token is required',
  INVALID_REFRESH_TOKEN: 'Invalid refresh token',
  REGISTRATION_FAILED: 'Failed to create user',
  ALREADY_LOGGED_OUT: 'User is already logged out',
} as const;
