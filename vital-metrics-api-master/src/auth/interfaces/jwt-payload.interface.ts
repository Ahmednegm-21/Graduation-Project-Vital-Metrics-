export interface JwtPayload {
  sub: number;
  email: string;
  is_admin: boolean;
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
}

export interface AuthResponse extends TokenResponse {
  user: {
    user_id: number;
    name: string;
    email: string;
    is_admin: boolean;
    is_verified: boolean;
  };
}
