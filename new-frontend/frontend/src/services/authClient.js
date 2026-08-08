import axios from "axios";
import { sendFrontendTelemetry } from "./frontendTelemetry";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "/api";

const authClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

authClient.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = String(error?.response?.status || 'network_error');
    const route = `${API_BASE_URL}${error?.config?.url || ''}`;

    sendFrontendTelemetry({
      eventName: status === '404' ? 'route_mismatch' : 'auth_request_error',
      route,
      status,
      view: 'auth-client',
    });

    return Promise.reject(error);
  }
);

export const loginUser = async ({ email, password }) => {
  const response = await authClient.post("/auth/login", {
    email,
    password,
  });

  return response.data;
};

export const verifyTwoFactorCode = async ({ email, otp, tempToken }) => {
  const response = await authClient.post("/auth/verify-2fa", {
    email,
    otp,
    tempToken,
  });

  return response.data;
};

export const resendTwoFactorCode = async ({ email, tempToken }) => {
  const response = await authClient.post("/auth/resend-2fa", {
    email,
    tempToken,
  });

  return response.data;
};

export const registerUser = async ({ fullName, email, password }) => {
  const response = await authClient.post("/auth/register", {
    fullName,
    email,
    password,
  });

  return response.data;
};

export const saveAuthSession = ({ token, user }) => {
  sessionStorage.setItem("iot_auth", "true");

  if (token) {
    sessionStorage.setItem("iot_token", token);
  }

  if (user) {
    sessionStorage.setItem("iot_user", JSON.stringify(user));
  }
};

export const clearAuthSession = () => {
  sessionStorage.removeItem("iot_auth");
  sessionStorage.removeItem("iot_token");
  sessionStorage.removeItem("iot_user");
  localStorage.removeItem("isAuthenticated");
};
