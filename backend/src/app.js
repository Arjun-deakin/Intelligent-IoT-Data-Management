const path = require('path');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const mockRoutes = require('./routes/mock');
const apiRouter = require('./routes');
const authRoutes = require('./routes/auth');
const thingSpeakRoutes = require('./routes/thingspeak');
const telemetryRoutes = require('./routes/telemetry');
const pool = require('./db/pool');
const {
  register,
  metricsMiddleware,
  dbHealthStatus,
  dbConnectionInfo
} = require('./monitoring/metrics');

const app = express();

const updateDatabaseHealthMetrics = async () => {
  try {
    await pool.query('SELECT 1');
    dbHealthStatus.set(1);
    dbConnectionInfo.reset();
    dbConnectionInfo.set({ status: 'Connected' }, 1);
    return true;
  } catch (error) {
    dbHealthStatus.set(0);
    dbConnectionInfo.reset();
    dbConnectionInfo.set({ status: 'Unhealthy' }, 1);
    return false;
  }
};

app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);

app.get('/', (req, res) => {
  res.send('Backend is running');
});

app.get('/health', async (req, res) => {
  const databaseHealthy = await updateDatabaseHealthMetrics();

  if (databaseHealthy) {
    return res.status(200).json({
      status: 'ok',
      database: 'healthy',
      timestamp: new Date().toISOString(),
      uptimeSeconds: process.uptime()
    });
  }

  return res.status(503).json({
    status: 'degraded',
    database: 'unhealthy',
    timestamp: new Date().toISOString(),
    uptimeSeconds: process.uptime()
  });
});

app.get('/metrics', async (_req, res) => {
  await updateDatabaseHealthMetrics();
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.use('/api', apiRouter);
app.use('/api', authRoutes);
app.use('/api', mockRoutes);
app.use('/api', thingSpeakRoutes);
app.use('/api', telemetryRoutes);

updateDatabaseHealthMetrics();
setInterval(updateDatabaseHealthMetrics, 15000);

module.exports = app;
