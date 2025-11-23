# Implementation Plan - WebSocket Migration

## Goal
Migrate from HTTP polling to WebSockets for real-time telemetry updates. This reduces overhead and provides smoother updates.

## User Review Required
> [!NOTE]
> **WebSocket Port**: Will use the same port (8000) and path `/ws`.
> **Fallback**: The HTTP endpoints will remain available.

## Proposed Changes

### Telemetry API (`telemetry_api/`)

#### [MODIFY] [main.py](file:///Users/mac/Desktop/Telemetry/telemetry_api/main.py)
- Import `WebSocket` from `fastapi` and `asyncio`.
- Add `websocket_endpoint` that:
  - Accepts connection.
  - Enters a loop.
  - Reads telemetry data.
  - Sends JSON data.
  - Sleeps for 2 seconds (configurable).

### Flutter App (`telemetry_app/`)

#### [MODIFY] [pubspec.yaml](file:///Users/mac/Desktop/Telemetry/telemetry_app/pubspec.yaml)
- Add `web_socket_channel` dependency.

#### [MODIFY] [telemetry_service.dart](file:///Users/mac/Desktop/Telemetry/telemetry_app/lib/services/telemetry_service.dart)
- Import `web_socket_channel`.
- Add `Stream<TelemetryData> getTelemetryStream()` method.
- Maintain `WebSocketChannel` connection.

#### [MODIFY] [home_screen.dart](file:///Users/mac/Desktop/Telemetry/telemetry_app/lib/screens/home_screen.dart)
- Remove `Timer`.
- Use `StreamBuilder` or listen to the stream in `initState`.
- Handle connection errors and reconnection logic.

## Verification Plan

### Manual Verification
1. **API**:
   - Use a tool like Postman or `wscat` to connect to `ws://localhost:8000/ws`.
   - Verify JSON data streams every 2 seconds.

2. **App**:
   - Run the app.
   - Verify data updates automatically without manual refresh.
   - Disconnect Pi (stop server) -> Verify app handles disconnect.
   - Reconnect Pi -> Verify app reconnects (might need manual retry button or auto-retry logic).
