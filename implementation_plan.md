# Implementation Plan - Telemetry Enhancements

## Goal
Enhance the Telemetry API and Flutter App with comprehensive system monitoring (Disk, CPU %, Network, Throttling) and Remote Control capabilities.

## User Review Required
> [!IMPORTANT]
> **Security Warning**: The Reboot and Shutdown features require the API to run with sufficient privileges (e.g., `sudo` or root).
> **Throttling Detection**: Requires `vcgencmd` to be available on the Pi.

## Proposed Changes

### Telemetry API (`telemetry_api/`)

#### [MODIFY] [telemetry_readers.py](file:///Users/mac/Desktop/Telemetry/telemetry_api/telemetry_readers.py)
- `get_disk_usage()`: Returns total, used, free, percent for `/`.
- `get_system_info()`: Returns hostname, OS version, kernel version, local IP.
- `get_cpu_usage()`: Returns CPU usage percentage (calculated from `/proc/stat`).
- `get_throttling_status()`: Returns under-voltage/frequency capping status using `vcgencmd get_throttled`.
- `get_network_stats()`: Returns bytes sent/received for `wlan0` (or primary interface).

#### [MODIFY] [main.py](file:///Users/mac/Desktop/Telemetry/telemetry_api/main.py)
- Update `TelemetryResponse` to include:
  - `disk`: Disk usage stats.
  - `info`: System info.
  - `cpu_usage`: CPU percentage.
  - `throttling`: Throttling status.
  - `network`: Network I/O stats.
- Add `POST /control/reboot` endpoint.
- Add `POST /control/shutdown` endpoint.

### Flutter App (`telemetry_app/`)

#### [MODIFY] [telemetry_data.dart](file:///Users/mac/Desktop/Telemetry/telemetry_app/lib/models/telemetry_data.dart)
- Update `TelemetryData` model to include new fields.
- Create helper classes for new data types.

#### [MODIFY] [telemetry_service.dart](file:///Users/mac/Desktop/Telemetry/telemetry_app/lib/services/telemetry_service.dart)
- Add `rebootSystem()` and `shutdownSystem()` methods.

#### [MODIFY] [home_screen.dart](file:///Users/mac/Desktop/Telemetry/telemetry_app/lib/screens/home_screen.dart)
- **New Cards**:
  - **Disk Usage**: Circular progress indicator.
  - **CPU Usage**: Gauge or progress bar (separate from Temp).
  - **Network**: Upload/Download speeds (calculated by diffing bytes over time).
  - **System Health**: Status indicator for Throttling (Green = OK, Red = Under-voltage).
- **Control Section**:
  - Floating Action Button or AppBar action to open "Control Panel" (Reboot/Shutdown).

## Verification Plan

### Manual Verification
1. **API Testing**:
   - `curl http://localhost:8000/telemetry` -> Verify all new fields are present.
   - `curl -X POST http://localhost:8000/control/reboot` -> Verify log output.

2. **Flutter App Testing**:
   - Verify all new widgets render correctly.
   - Verify Network speed updates (requires 2+ fetches to calculate diff).
   - Test Control buttons.
