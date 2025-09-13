import type { FormEvent } from "react";
import React, { useState } from "react";
import axios, { AxiosError } from "axios";
import type { LoginDto, LoginResponse, LoginProps } from "../types/auth";
import "./Login.css";

const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [message, setMessage] = useState<string>("");

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setMessage("");

    const loginDto: LoginDto = { email, password };

    try {
      const response = await axios.post<LoginResponse>(
        "http://localhost:5187/api/auth/login",
        loginDto,
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
      const { token } = response.data;
      localStorage.setItem("token", token); // Lưu token vào localStorage
      setMessage("Login successful!");
      onLogin(); // Gọi callback để cập nhật trạng thái
      setEmail("");
      setPassword("");
    } catch (error) {
      const axiosError = error as AxiosError<{ message: string }>;
      setMessage(axiosError.response?.data?.message || "Login failed");
    }
  };

  return (
    <div className="login-container">
      <h2>Login to PicSocial</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Email:</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>
        <div className="form-group">
          <label>Password:</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>
        <button type="submit">Login</button>
      </form>
      {message && (
        <p className={message.includes("success") ? "success" : "error"}>
          {message}
        </p>
      )}
    </div>
  );
};

export default Login;
