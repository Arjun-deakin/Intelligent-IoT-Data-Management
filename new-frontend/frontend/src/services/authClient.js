import axios from "axios";
import { sendFrontendTelemetry } from "./frontendTelemetry";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "/api";

let accessToken = null;

const readStoredToken = () => sessionStorage.getItem("iot_token");

const authClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,
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

export const loginUser = async ({ email, password, rememberMe = false }) => {
  const response = await authClient.post("/auth/login", {
    email,
    password,
    rememberMe,
  });

  return response.data.data;
};

export const getAccessToken = () => accessToken || readStoredToken();

export const setAccessToken = (token) => {
  accessToken = token || null;
};

export const clearAccessToken = () => {
  accessToken = null;
};

export const verifyTwoFactorCode = async ({
  mfaChallengeId,
  otp,
  rememberMe = false,
}) => {
  const response = await authClient.post("/auth/mfa/verify", {
    mfaChallengeId,
    otp,
    rememberMe,
  });

  return response.data.data;
};

export const resendTwoFactorCode = async ({ mfaChallengeId }) => {
  const response = await authClient.post("/auth/mfa/resend", {
    mfaChallengeId,
  });

  return response.data.data;
};

export const registerUser = async ({ email, password, confirmPassword }) => {
  const response = await authClient.post("/auth/register", {
    email,
    password,
    confirmPassword,
  });

  return response.data.data;
};

export const refreshSession = async () => {
  const response = await authClient.post("/auth/refresh");
  const token = response.data?.data?.accessToken;

  setAccessToken(token);

  return response.data;
};

export const logoutUser = async () => {
  try {
    await authClient.post(
      "/auth/logout",
      null,
      accessToken
        ? {
            headers: {
              Authorization: `Bearer ${accessToken}`,
            },
          }
        : undefined
    );
  } finally {
    clearAuthSession();
  }
};

export const saveAuthSession = ({ token, accessToken, user }) => {
  const resolvedToken = accessToken || token || null;

  setAccessToken(resolvedToken);
  sessionStorage.setItem("iot_auth", "true");

  if (resolvedToken) {
    sessionStorage.setItem("iot_token", resolvedToken);
  }

  if (user) {
    sessionStorage.setItem("iot_user", JSON.stringify(user));
  }
};

export const clearAuthSession = () => {
  clearAccessToken();
  sessionStorage.removeItem("iot_auth");
  sessionStorage.removeItem("iot_token");
  sessionStorage.removeItem("iot_user");
  localStorage.removeItem("isAuthenticated");
};
