import React, { useRef, useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import {
  loginUser,
  verifyTwoFactorCode,
  resendTwoFactorCode,
  saveAuthSession,
} from "../services/authClient";
import "./Login.css";

function Login() {
  const navigate = useNavigate();

  const [step, setStep] = useState(1);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [showPassword, setShowPassword] = useState(false);
  const [otp, setOtp] = useState(["", "", "", "", "", ""]);
  const [message, setMessage] = useState("");
  const [messageType, setMessageType] = useState("");
  const [mfaChallengeId, setMfaChallengeId] = useState(null);
  const [rememberMe, setRememberMe] = useState(false);
  const [loading, setLoading] = useState(false);

  const inputRefs = useRef([]);

  useEffect(() => {
    if (sessionStorage.getItem("register_success") === "true") {
      setMessage("Account created successfully. Please sign in.");
      setMessageType("success");
      sessionStorage.removeItem("register_success");
    }
  }, []);

  const handleLoginSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage("");

    try {
      const result = await loginUser({ email, password, rememberMe });

      if (result?.mfaChallengeId) {
        setMfaChallengeId(result.mfaChallengeId);
        setMessage("");
        setStep(2);
        return;
      }

      saveAuthSession(result);
      navigate("/home");
    } catch (err) {
      setMessage(
        err?.response?.data?.error?.message ||
          "Unable to sign in. Please try again."
      );
      setMessageType("error");
    } finally {
      setLoading(false);
    }
  };

  const handleOtpChange = (value, index) => {
    if (!/^\d?$/.test(value)) return;

    const updatedOtp = [...otp];
    updatedOtp[index] = value;
    setOtp(updatedOtp);

    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (e, index) => {
    if (e.key === "Backspace" && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handleVerifyCode = async (e) => {
    e.preventDefault();
    setMessage("");

    const enteredCode = otp.join("");

    if (enteredCode.length !== 6) {
      setMessage("Please enter the 6-digit verification code.");
      setMessageType("error");
      return;
    }

    setLoading(true);

    try {
      const session = await verifyTwoFactorCode({
        mfaChallengeId,
        otp: enteredCode,
        rememberMe,
      });

      saveAuthSession(session);
      navigate("/home");
    } catch (err) {
      setMessage(
        err?.response?.data?.error?.message ||
          "Invalid verification code."
      );
      setMessageType("error");
    } finally {
      setLoading(false);
    }
  };

  const handleResendCode = async () => {
    if (!mfaChallengeId) {
      setMessage("Please sign in again to get a new code.");
      setMessageType("error");
      return;
    }

    setLoading(true);
    setMessage("");

    try {
      await resendTwoFactorCode({ mfaChallengeId });
      setMessage("A new verification code has been sent.");
      setMessageType("success");
    } catch (err) {
      setMessage(
        err?.response?.data?.error?.message ||
          "Unable to resend the code."
      );
      setMessageType("error");
    } finally {
      setLoading(false);
    }
  };

  const handleBackToLogin = () => {
    setStep(1);
    setOtp(["", "", "", "", "", ""]);
    setMessage("");
  };

  return (
    <main className="login-page">
      <section className="login-card">
        <div className="login-logo">
          <span>IoT</span>
        </div>

        {step === 1 ? (
          <>
            <h1>Welcome Back</h1>

            <p className="login-subtitle">
              Sign in to continue to Intelligent IoT Data Management.
            </p>

            {message && (
              <p
                className={`form-alert ${
                  messageType === "success" ? "success-alert" : "error-alert"
                }`}
              >
                {message}
              </p>
            )}

            <form className="login-form" onSubmit={handleLoginSubmit}>
              <div className="form-group">
                <label>Email Address</label>
                <input
                  type="email"
                  placeholder="Enter your email address"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label>Password</label>

                <div className="password-wrapper">
                  <input
                    type={showPassword ? "text" : "password"}
                    placeholder="Enter your password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />

                  <button
                    type="button"
                    className="password-toggle"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? "Hide" : "Show"}
                  </button>
                </div>
              </div>

              <div className="login-options">
                <label className="remember-me">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                  />
                  Remember me
                </label>

                <Link to="/forgot-password" className="forgot-link">
                  Forgot password?
                </Link>
              </div>

              <button type="submit" className="login-button" disabled={loading}>
                {loading ? "Signing in..." : "Login"}
              </button>
            </form>

            <p className="signup-text">
              Don&apos;t have an account? <Link to="/register">Sign up</Link>
            </p>
          </>
        ) : (
          <>
            <h1>Two-Factor Authentication</h1>

            <p className="login-subtitle">
              Enter the 6-digit verification code sent to your email address.
            </p>

            {message && (
              <p
                className={`form-alert ${
                  messageType === "success" ? "success-alert" : "error-alert"
                }`}
              >
                {message}
              </p>
            )}

            <form className="login-form" onSubmit={handleVerifyCode}>
              <div className="otp-container">
                {otp.map((digit, index) => (
                  <input
                    key={index}
                    type="text"
                    maxLength="1"
                    className="otp-input"
                    value={digit}
                    onChange={(e) => handleOtpChange(e.target.value, index)}
                    onKeyDown={(e) => handleKeyDown(e, index)}
                    ref={(el) => (inputRefs.current[index] = el)}
                  />
                ))}
              </div>

              <button type="submit" className="login-button" disabled={loading}>
                {loading ? "Verifying..." : "Verify Code"}
              </button>
            </form>

            <div className="twofactor-actions">
              <button
                type="button"
                className="text-button"
                onClick={handleResendCode}
              >
                Resend Code
              </button>

              <button
                type="button"
                className="text-button"
                onClick={handleBackToLogin}
              >
                Back to Login
              </button>
            </div>
          </>
        )}
      </section>
    </main>
  );
}

export default Login;
