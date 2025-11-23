# Telemetry App Enhancements Walkthrough

I have added three major features to the Telemetry App: Network Discovery, Historical Graphs, and Smart Alerts. Additionally, I have migrated the data fetching mechanism to use WebSockets for real-time updates.

## 1. Network Discovery

You can now automatically find your Raspberry Pi on the network without typing the IP address.

### How to use:
1. Open the app.
2. Click the **Settings** (gear) icon in the top right.
3. Click the **Search** (magnifying glass) icon in the "API URL" field.
4. The app will scan for devices advertising `_http._tcp` (standard for web servers).
5. Select your Pi from the list to automatically fill in the IP.

> [!NOTE]
> Ensure your Pi is connected to the same Wi-Fi network.

## 2. Historical Graphs

The app now tracks the last 60 seconds (approx) of system metrics.

### Features:
- **CPU Usage**: Blue line graph.
- **Memory Usage**: Purple line graph.
- **CPU Temperature**: Orange line graph.

These graphs are located at the bottom of the Home Screen. Scroll down to view them.

## 3. Smart Alerts

The app proactively monitors system health and alerts you if something is wrong.

### Triggers:
- **High CPU Temp**: > 80°C
- **Disk Full**: > 90% usage
- **Throttling**: Any system throttling (under-voltage, etc.)

Alerts appear as a red SnackBar at the bottom of the screen.

## 4. WebSocket Integration

The app now uses WebSockets (`ws://`) instead of HTTP polling (`http://`) for telemetry data. This ensures smoother, real-time updates with less network overhead.

## Code Changes

### Dependencies
- Added `fl_chart` for rendering graphs.
- Added `nsd` for network service discovery.
- Added `web_socket_channel` for WebSocket support.

### Files Modified
- `lib/screens/home_screen.dart`: Replaced `Timer` with `StreamSubscription`.
- `lib/services/telemetry_service.dart`: Added `getTelemetryStream` using WebSockets.
- `telemetry_api/main.py`: Added `/ws` endpoint.
