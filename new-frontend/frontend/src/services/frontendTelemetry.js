const TELEMETRY_ENDPOINT = '/api/telemetry/frontend-event';

export const sendFrontendTelemetry = ({
  eventName,
  route,
  status,
  durationMs,
  view,
}) => {
  const payload = {
    eventName,
    route,
    status,
    durationMs,
    view,
    reportedAt: new Date().toISOString(),
  };

  const body = JSON.stringify(payload);

  if (typeof navigator !== 'undefined' && navigator.sendBeacon) {
    const blob = new Blob([body], { type: 'application/json' });
    navigator.sendBeacon(TELEMETRY_ENDPOINT, blob);
    return;
  }

  fetch(TELEMETRY_ENDPOINT, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body,
    keepalive: true,
  }).catch(() => {});
};
