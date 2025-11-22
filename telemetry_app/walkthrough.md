# Flutter Telemetry App Walkthrough

I have created a minimal and beautiful Flutter application to display telemetry data from your Raspberry Pi API.

## Features
- **Real-time Monitoring**: Auto-refreshes every 5 seconds.
- **Minimal Design**: Dark mode with glassmorphic cards and animations.
- **Visual Indicators**: Color-coded metrics (Green/Orange/Red) based on values.
- **Configurable**: Settings dialog to change the API URL (defaults to `http://localhost:8000`).

## Project Structure
- `lib/models/telemetry_data.dart`: JSON parsing logic.
- `lib/services/telemetry_service.dart`: API communication.
- `lib/widgets/telemetry_card.dart`: Reusable UI component.
- `lib/screens/home_screen.dart`: Main dashboard.
- `lib/main.dart`: App entry point and theme.

## How to Run
1. **Start the API** (if not already running):
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

3. **Configure IP**:
   - If running on a real device or different machine, tap the Settings icon in the app.
   - Enter your Raspberry Pi's IP address (e.g., `http://192.168.1.100:8000`).
