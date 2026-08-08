const client = require('prom-client');

const register = new client.Registry();

client.collectDefaultMetrics({
  register,
  prefix: 'iot_platform_'
});

const httpRequestDurationSeconds = new client.Histogram({
  name: 'iot_http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.05, 0.1, 0.25, 0.5, 1, 2, 5]
});

const httpRequestsTotal = new client.Counter({
  name: 'iot_http_requests_total',
  help: 'Total HTTP requests handled by the backend',
  labelNames: ['method', 'route', 'status_code']
});

const dbQueryDurationSeconds = new client.Histogram({
  name: 'iot_db_query_duration_seconds',
  help: 'Database query duration in seconds',
  labelNames: ['operation', 'status'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1]
});

const dbQueriesTotal = new client.Counter({
  name: 'iot_db_queries_total',
  help: 'Total database queries executed',
  labelNames: ['operation', 'status']
});

const dbHealthStatus = new client.Gauge({
  name: 'iot_db_health_status',
  help: 'Database health status where 1 means healthy and 0 means unhealthy'
});

const dbConnectionInfo = new client.Gauge({
  name: 'iot_db_connection_info',
  help: 'Database connection information exposed through a status label',
  labelNames: ['status']
});

const thingspeakPollsTotal = new client.Counter({
  name: 'iot_thingspeak_polls_total',
  help: 'Total ThingSpeak polling attempts',
  labelNames: ['status']
});

const thingspeakPollDurationSeconds = new client.Histogram({
  name: 'iot_thingspeak_poll_duration_seconds',
  help: 'ThingSpeak poll duration in seconds',
  labelNames: ['status'],
  buckets: [0.1, 0.25, 0.5, 1, 2, 5, 10]
});

const thingspeakRowsInsertedTotal = new client.Counter({
  name: 'iot_thingspeak_rows_inserted_total',
  help: 'Total ThingSpeak rows inserted into the database'
});

const thingspeakLastRowsInserted = new client.Gauge({
  name: 'iot_thingspeak_last_rows_inserted',
  help: 'Rows inserted during the latest ThingSpeak poll cycle'
});

const thingspeakRetryCountTotal = new client.Counter({
  name: 'iot_thingspeak_retry_count_total',
  help: 'Total number of ThingSpeak retry attempts performed'
});

const frontendEventsTotal = new client.Counter({
  name: 'iot_frontend_events_total',
  help: 'Total frontend telemetry events received by the backend',
  labelNames: ['event_name', 'route', 'status']
});

const frontendRenderDurationMilliseconds = new client.Histogram({
  name: 'iot_frontend_render_duration_milliseconds',
  help: 'Frontend render or UI timing values reported from the browser in milliseconds',
  labelNames: ['view'],
  buckets: [100, 250, 500, 1000, 2000, 3000, 5000]
});

const frontendRouteMismatchTotal = new client.Counter({
  name: 'iot_frontend_route_mismatch_total',
  help: 'Total frontend calls that hit a mismatched or missing route',
  labelNames: ['route', 'status']
});

register.registerMetric(httpRequestDurationSeconds);
register.registerMetric(httpRequestsTotal);
register.registerMetric(dbQueryDurationSeconds);
register.registerMetric(dbQueriesTotal);
register.registerMetric(dbHealthStatus);
register.registerMetric(dbConnectionInfo);
register.registerMetric(thingspeakPollsTotal);
register.registerMetric(thingspeakPollDurationSeconds);
register.registerMetric(thingspeakRowsInsertedTotal);
register.registerMetric(thingspeakLastRowsInserted);
register.registerMetric(thingspeakRetryCountTotal);
register.registerMetric(frontendEventsTotal);
register.registerMetric(frontendRenderDurationMilliseconds);
register.registerMetric(frontendRouteMismatchTotal);

dbHealthStatus.set(0);
dbConnectionInfo.set({ status: 'Unknown' }, 1);
thingspeakLastRowsInserted.set(0);

const normalizeRoute = (req) => {
  if (req.route && req.route.path) {
    const routePath = Array.isArray(req.route.path)
      ? req.route.path.join('|')
      : req.route.path;
    return `${req.baseUrl || ''}${routePath}` || req.path;
  }

  return req.baseUrl || req.path || 'unmatched';
};

const metricsMiddleware = (req, res, next) => {
  const start = process.hrtime.bigint();

  res.on('finish', () => {
    const durationSeconds = Number(process.hrtime.bigint() - start) / 1e9;
    const route = normalizeRoute(req);
    const labels = {
      method: req.method,
      route,
      status_code: String(res.statusCode)
    };

    httpRequestDurationSeconds.observe(labels, durationSeconds);
    httpRequestsTotal.inc(labels);
  });

  next();
};

module.exports = {
  client,
  register,
  metricsMiddleware,
  httpRequestDurationSeconds,
  httpRequestsTotal,
  dbQueryDurationSeconds,
  dbQueriesTotal,
  dbHealthStatus,
  dbConnectionInfo,
  thingspeakPollsTotal,
  thingspeakPollDurationSeconds,
  thingspeakRowsInsertedTotal,
  thingspeakLastRowsInserted,
  thingspeakRetryCountTotal,
  frontendEventsTotal,
  frontendRenderDurationMilliseconds,
  frontendRouteMismatchTotal
};
