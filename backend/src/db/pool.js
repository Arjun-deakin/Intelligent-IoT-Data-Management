require('dotenv').config({
  path: require('path').resolve(__dirname, '../../.env')
});

const { Pool } = require('pg');
const {
  dbQueryDurationSeconds,
  dbQueriesTotal
} = require('../monitoring/metrics');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT
});

const inferOperation = (queryText) => {
  if (typeof queryText !== 'string') {
    return 'unknown';
  }

  const operation = queryText.trim().split(/\s+/)[0];
  return operation ? operation.toUpperCase() : 'unknown';
};

const originalQuery = pool.query.bind(pool);

pool.query = async (...args) => {
  const operation = inferOperation(args[0]);
  const start = process.hrtime.bigint();

  try {
    const result = await originalQuery(...args);
    const durationSeconds = Number(process.hrtime.bigint() - start) / 1e9;
    dbQueryDurationSeconds.observe({ operation, status: 'success' }, durationSeconds);
    dbQueriesTotal.inc({ operation, status: 'success' });
    return result;
  } catch (error) {
    const durationSeconds = Number(process.hrtime.bigint() - start) / 1e9;
    dbQueryDurationSeconds.observe({ operation, status: 'error' }, durationSeconds);
    dbQueriesTotal.inc({ operation, status: 'error' });
    throw error;
  }
};

module.exports = pool;
