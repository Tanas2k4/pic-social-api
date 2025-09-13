export interface LoginDto {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
}

export interface LoginProps {
  onLogin: () => void;
}
