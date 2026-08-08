const express = require('express');
const {
  frontendEventsTotal,
  frontendRenderDurationMilliseconds,
  frontendRouteMismatchTotal
} = require('../monitoring/metrics');

const router = express.Router();

router.post('/telemetry/frontend-event', (req, res) => {
  const {
    eventName = 'unknown',
    route = 'unknown',
    status = 'unknown',
    durationMs,
    view
  } = req.body || {};

  frontendEventsTotal.inc({
    event_name: String(eventName),
    route: String(route),
    status: String(status)
  });

  if (typeof durationMs === 'number' && Number.isFinite(durationMs)) {
    frontendRenderDurationMilliseconds.observe(
      { view: String(view || route || 'unknown') },
      durationMs
    );
  }

  if (eventName === 'route_mismatch' || status === '404') {
    frontendRouteMismatchTotal.inc({
      route: String(route),
      status: String(status)
    });
  }

  res.status(202).json({ accepted: true });
});

module.exports = router;
