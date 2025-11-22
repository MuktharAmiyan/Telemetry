# Flutter Telemetry App Walkthrough

I have enhanced the Telemetry App with comprehensive system monitoring and control capabilities.

## New Features
- **Expanded Metrics**:
  - **CPU Usage**: Real-time percentage gauge.
  - **Disk Usage**: Storage monitoring with free space indicator.
  - **Network Speed**: Real-time download/upload speed tracking.
  - **System Health**: Throttling detection (Under-voltage/Overheating).
- **Control Panel**:
  - **Reboot**: Remote system restart.
  - **Shutdown**: Remote system power off.
  - *Note*: Requires `sudo` privileges on the Pi.

## Project Structure
- `lib/models/telemetry_data.dart`: Updated with `DiskData`, `NetworkData`, `SystemInfo`, etc.
- `lib/services/telemetry_service.dart`: Added `rebootSystem()` and `shutdownSystem()`.
- `lib/screens/home_screen.dart`: Added new widgets and Control Panel bottom sheet.

## How to Run
1. **Start the API**:
   ```bash
   # In the Telemetry directory
   source venv/bin/activate
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

2. **Run the Flutter App**:
   ```bash
   cd telemetry_app
   flutter run
   ```

3. **Using Controls**:
   - Tap the **Power Icon** in the top right to open the Control Panel.
   - Select **Reboot** or **Shutdown**.
   - Confirm the action in the dialog.

## Screenshots
(Screenshots would appear here if I could run the app visually)
