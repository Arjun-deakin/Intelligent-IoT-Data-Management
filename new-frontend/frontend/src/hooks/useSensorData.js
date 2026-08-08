import { useState, useEffect } from 'react';
import SensorData1 from '../data/sensorData1.json';
import { sendFrontendTelemetry } from '../services/frontendTelemetry';

export const useSensorData = (useMock = true, endpoint = '/api/streams') => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (useMock) {
      setData(SensorData1);
      setLoading(false);
      return;
    }

    const startedAt = performance.now();

    fetch(endpoint)
      .then(async (res) => {
        if (!res.ok) {
          const error = new Error(`Request failed with status ${res.status}`);
          error.status = res.status;
          throw error;
        }

        return res.json();
      })
      .then((json) => {
        setData(json);
        setLoading(false);

        sendFrontendTelemetry({
          eventName: 'dashboard_data_loaded',
          route: endpoint,
          status: '200',
          durationMs: Math.round(performance.now() - startedAt),
          view: 'dashboard',
        });
      })
      .catch((err) => {
        setError(err);
        setLoading(false);

        sendFrontendTelemetry({
          eventName: err?.status === 404 ? 'route_mismatch' : 'dashboard_data_error',
          route: endpoint,
          status: String(err?.status || 'fetch_error'),
          durationMs: Math.round(performance.now() - startedAt),
          view: 'dashboard',
        });
      });
  }, [useMock, endpoint]);

  return { data, loading, error };
};
