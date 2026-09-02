# Pilot Runbook

This runbook is for the `merge-lukitasxue-aintl` branch pilot flow where Backend and Analytics Intelligence are connected end-to-end.

## Pilot Scope

Included services:

- `frontend`
- `backend`
- `db`
- `analytics-integration`

Primary runtime path:

`Frontend -> POST /api/analyse -> Backend -> Analytics Intelligence -> Backend response`

The backend also runs live ThingSpeak ingestion into PostgreSQL using the `thingspeak-live` dataset.

## Start The Pilot Stack

From the repository root:

```bash
docker compose up --build -d
```

## Stop The Pilot Stack

```bash
docker compose down
```

To remove the PostgreSQL volume:

```bash
docker compose down -v
```

## Service URLs

- Frontend: `http://localhost:5173`
- Backend API: `http://localhost:3000`
- Backend health: `http://localhost:3000/health`
- Analytics Intelligence health: `http://localhost:5002/health`
- PostgreSQL: `localhost:5432`

## Runtime Configuration

The pilot stack uses:

- `THINGSPEAK_CHANNEL_ID=1350261`
- `THINGSPEAK_RESULTS=10`
- `THINGSPEAK_POLL_INTERVAL_MS=15000`
- `THINGSPEAK_MAX_RETRIES=3`
- `THINGSPEAK_RETRY_DELAY_MS=2000`
- `THINGSPEAK_DATASET_NAME=thingspeak-live`
- `ANALYTICS_SERVICE_URL=http://analytics-integration:5002`
- `ANALYTICS_TIMEOUT_MS=15000`
- `JWT_SECRET=dev_secret_key`

## Quick Validation

Check Analytics Intelligence:

```bash
curl http://localhost:5002/health
```

Expected:

```json
{
  "service": "analytics-integration",
  "status": "ok"
}
```

Check Backend:

```bash
curl http://localhost:3000/health
```

Check the analysis path:

```bash
curl -X POST http://localhost:3000/api/analyse \
  -H "Content-Type: application/json" \
  -d '{
    "data": [
      {"timestamp":"2026-08-27T00:00:00.000Z","temperature":24.2,"humidity":50.5,"pressure":1012.8},
      {"timestamp":"2026-08-27T00:01:00.000Z","temperature":24.4,"humidity":51.0,"pressure":1013.2},
      {"timestamp":"2026-08-27T00:02:00.000Z","temperature":24.5,"humidity":51.1,"pressure":1013.1},
      {"timestamp":"2026-08-27T00:03:00.000Z","temperature":24.6,"humidity":51.0,"pressure":1013.0},
      {"timestamp":"2026-08-27T00:04:00.000Z","temperature":24.7,"humidity":50.9,"pressure":1012.9},
      {"timestamp":"2026-08-27T00:05:00.000Z","temperature":24.7,"humidity":50.8,"pressure":1012.9},
      {"timestamp":"2026-08-27T00:06:00.000Z","temperature":24.8,"humidity":50.7,"pressure":1012.8},
      {"timestamp":"2026-08-27T00:07:00.000Z","temperature":24.8,"humidity":50.6,"pressure":1012.8},
      {"timestamp":"2026-08-27T00:08:00.000Z","temperature":24.9,"humidity":50.5,"pressure":1012.7},
      {"timestamp":"2026-08-27T00:09:00.000Z","temperature":24.9,"humidity":50.4,"pressure":1012.7},
      {"timestamp":"2026-08-27T00:10:00.000Z","temperature":25.0,"humidity":50.3,"pressure":1012.6},
      {"timestamp":"2026-08-27T00:11:00.000Z","temperature":25.0,"humidity":50.2,"pressure":1012.6},
      {"timestamp":"2026-08-27T00:12:00.000Z","temperature":25.1,"humidity":50.1,"pressure":1012.5},
      {"timestamp":"2026-08-27T00:13:00.000Z","temperature":25.1,"humidity":50.0,"pressure":1012.5},
      {"timestamp":"2026-08-27T00:14:00.000Z","temperature":25.2,"humidity":49.9,"pressure":1012.4},
      {"timestamp":"2026-08-27T00:15:00.000Z","temperature":25.2,"humidity":49.8,"pressure":1012.4},
      {"timestamp":"2026-08-27T00:16:00.000Z","temperature":25.3,"humidity":49.7,"pressure":1012.3},
      {"timestamp":"2026-08-27T00:17:00.000Z","temperature":25.3,"humidity":49.6,"pressure":1012.3},
      {"timestamp":"2026-08-27T00:18:00.000Z","temperature":25.4,"humidity":49.5,"pressure":1012.2},
      {"timestamp":"2026-08-27T00:19:00.000Z","temperature":25.4,"humidity":49.4,"pressure":1012.2}
    ],
    "model": {"metric":"temperature"},
    "correlation": {"streams":["temperature","humidity"]}
  }'
```

Expected:

- HTTP `200`
- `status: success`
- real analytics response from AIntl

## Notes

- Frontend should call Backend only, not Analytics Intelligence directly.
- Backend stores ThingSpeak data in PostgreSQL under the `thingspeak-live` dataset.
- Some legacy/mock routes still exist in the repository, but they are not the intended pilot path.
