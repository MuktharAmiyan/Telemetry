# Raspberry Pi Home Telemetry System

This project consists of two main components: a Python-based API server running on a Raspberry Pi, and a Flutter mobile application to visualize the telemetry data.

## Project Structure

- **`telemetry_api/`**: The backend API server.
  - Built with FastAPI and Python.
  - Runs on the Raspberry Pi Zero 2 W.
  - Exposes system metrics (CPU temp, Wi-Fi signal, Memory, Uptime) via JSON endpoints.
  - See [telemetry_api/README.md](telemetry_api/README.md) for installation and setup instructions.

- **`telemetry_app/`**: The mobile dashboard application.
  - Built with Flutter.
  - Runs on iOS and Android.
  - Connects to the API to display real-time metrics.
  - Features a minimal, dark-themed UI.
  - See [telemetry_app/README.md](telemetry_app/README.md) (or the `walkthrough.md` inside) for details.

## Quick Start

### 1. Set up the API on Raspberry Pi
Navigate to the `telemetry_api` directory and follow the setup instructions to get the server running.

```bash
cd telemetry_api
bash setup.sh
```

### 2. Run the Flutter App
Navigate to the `telemetry_app` directory and run the app.

```bash
cd telemetry_app
flutter run
```
