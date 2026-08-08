//handles server setup and configuration for the Express backend

const path = require('path');

require('dotenv').config({
  path: path.resolve(__dirname, '../.env')
});

const express = require('express');
const cors = require('cors');
const pool = require('./db/pool');
const {
  register,
  client,
  metricsMiddleware,
  dbHealthStatus,
  dbConnectionInfo
} = require('./monitoring/metrics');

// Your CSR routing structure (datasets, series, timestamps, analyse, etc.)
const apiRouter = require('./routes'); // loads index.js inside /routes

// Upstream routes
const mockRoutes = require('./routes/mock');
const thingSpeakRoutes = require('./routes/thingspeak');
const authRoutes = require('./routes/auth');
const telemetryRoutes = require('./routes/telemetry');


const { startThingSpeakPolling } = require('./services/thingspeakService');

// Debug-only imports (commented out for production)
/// const authMiddleware = require("./middleware/authMiddleware");
/// const { hashPassword, comparePassword } = require("./utils/hashUtils");
/// const { generateToken } = require("./utils/tokenUtils");

const app = express();

const updateDatabaseHealthMetrics = async () => {
  try {
    await pool.query('SELECT 1');
    dbHealthStatus.set(1);
    dbConnectionInfo.reset();
    dbConnectionInfo.set({ status: 'Connected' }, 1);
  } catch (error) {
    dbHealthStatus.set(0);
    dbConnectionInfo.reset();
    dbConnectionInfo.set({ status: 'Unhealthy' }, 1);
  }
};

app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);

// Root ping
app.get('/', (req, res) => {
  res.send('Backend is running');
});

app.get('/health', async (req, res) => {
  try {
    await updateDatabaseHealthMetrics();

    res.status(200).json({
      status: 'ok',
      database: 'healthy',
      timestamp: new Date().toISOString(),
      uptimeSeconds: process.uptime()
    });
  } catch (error) {
    await updateDatabaseHealthMetrics();

    res.status(503).json({
      status: 'degraded',
      database: 'unhealthy',
      timestamp: new Date().toISOString(),
      uptimeSeconds: process.uptime(),
      message: error.message
    });
  }
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

updateDatabaseHealthMetrics();
setInterval(updateDatabaseHealthMetrics, 15000);

/* ---------------------------------------------------------
   DEBUG ROUTES (COMMENTED OUT FOR PRODUCTION)
   --------------------------------------------------------- */

/// // TEST: bcrypt hashing
/// app.get("/api/hash-test", async (req, res) => {
///   const password = "test123";
///   const hash = await hashPassword(password);
///   res.json({ password, hash });
/// });

/// // TEST: bcrypt compare
/// app.get("/api/compare-test", async (req, res) => {
///   const password = "test123";
///   const wrong = "wrong123";
///
///   const hash = await hashPassword(password);
///
///   const match = await comparePassword(password, hash);
///   const wrongMatch = await comparePassword(wrong, hash);
///
///   res.json({ match, wrongMatch });
/// });

/// // TEST: generate JWT
/// app.get("/api/test-token", (req, res) => {
///   const token = generateToken({ id: 1, role: "admin" });
///   res.json({ token });
/// });

/// // PROTECTED ROUTE TEST
/// app.get("/api/protected", authMiddleware, (req, res) => {
///   res.json({
///     message: "Access granted",
///     user: req.user,
///   });
/// });

/* ---------------------------------------------------------
   END DEBUG ROUTES
   --------------------------------------------------------- */

// Mount original API routes (datasets, series, timestamps, analyse, etc.)
app.use('/api', apiRouter);

// Mount UPSTREAM routes (auth, mock, thingspeak)
app.use('/api', authRoutes);
app.use('/api', mockRoutes);
app.use('/api', thingSpeakRoutes);
app.use('/api', telemetryRoutes);

// Start server
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  startThingSpeakPolling();
});
