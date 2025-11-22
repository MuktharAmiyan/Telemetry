# Home Telemetry API for Raspberry Pi Zero 2 W

A lightweight FastAPI server that exposes Raspberry Pi system telemetry data (CPU temperature, Wi-Fi signal strength, uptime, memory) as JSON endpoints for easy integration with Flutter apps and other HTTP clients.

## Features

- **CPU Temperature**: Real-time CPU temperature monitoring
- **Wi-Fi Signal**: Signal strength (dBm) and quality (%)
- **System Metrics**: Uptime and load average
- **Memory Stats**: Total, used, free, and available memory
- **RESTful API**: Clean JSON responses with comprehensive endpoints
- **Auto-generated Docs**: Interactive API documentation via FastAPI
- **CORS Enabled**: Ready for cross-origin requests from Flutter apps
- **Systemd Service**: Auto-start on boot with automatic restart

## Prerequisites

- Raspberry Pi OS Lite (64-bit recommended)
- Python 3.7 or higher
- SSH access enabled
- Network connectivity

## Installation

### 1. Clone or Transfer Files

Transfer the project files to your Raspberry Pi:

```bash
# Option 1: Clone from repository
git clone <repository-url>
cd Telemetry

# Option 2: Transfer via SCP
scp -r Telemetry/ pi@<raspberry-pi-ip>:~/
ssh pi@<raspberry-pi-ip>
cd ~/Telemetry
```

### 2. Run Setup Script

The setup script will create a Python virtual environment and install all dependencies:

```bash
chmod +x setup.sh
bash setup.sh
```

### 3. Test the API

Start the API server manually to test:

```bash
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000
```

Or simply:

```bash
source venv/bin/activate
python main.py
```

The API will be available at `http://<your-pi-ip>:8000`

## API Endpoints

### Base Endpoint

**`GET /`**  
Returns API information and available endpoints.

```json
{
  "name": "Home Telemetry API",
  "version": "1.0.0",
  "description": "Raspberry Pi system monitoring API",
  "endpoints": { ... }
}
```

### Health Check

**`GET /health`**  
Simple health check endpoint.

```json
{
  "status": "healthy",
  "service": "telemetry-api"
}
```

### All Telemetry Data

**`GET /telemetry`**  
Returns all system telemetry data in a single response.

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "cpu": {
      "temperature_celsius": 42.5
    },
    "wifi": {
      "signal_level_dbm": -45,
      "signal_quality_percent": 85.71
    },
    "system": {
      "uptime_seconds": 86400.5,
      "uptime_hours": 24.0,
      "load_average": {
        "load_1min": 0.15,
        "load_5min": 0.10,
        "load_15min": 0.08
      }
    },
    "memory": {
      "total_mb": 512.0,
      "free_mb": 128.0,
      "available_mb": 256.0,
      "used_mb": 256.0,
      "used_percent": 50.0
    }
  }
}
```

### Individual Endpoints

**`GET /telemetry/cpu`**  
CPU temperature only.

**`GET /telemetry/wifi`**  
Wi-Fi signal strength and quality only.

**`GET /telemetry/system`**  
System uptime and load average only.

**`GET /telemetry/memory`**  
Memory statistics only.

### Interactive Documentation

**`GET /docs`**  
FastAPI auto-generated interactive documentation (Swagger UI).

**`GET /redoc`**  
Alternative documentation interface (ReDoc).

## Setting Up as a System Service

To run the API automatically on boot:

### 1. Update Service File Paths

Edit `telemetry-api.service` and update the paths to match your installation:

```bash
nano telemetry-api.service
```

Update these lines:
```ini
WorkingDirectory=/home/pi/Telemetry
Environment="PATH=/home/pi/Telemetry/venv/bin"
ExecStart=/home/pi/Telemetry/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
```

### 2. Install Service

```bash
sudo cp telemetry-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable telemetry-api
sudo systemctl start telemetry-api
```

### 3. Check Service Status

```bash
sudo systemctl status telemetry-api
```

### 4. View Logs

```bash
# View recent logs
sudo journalctl -u telemetry-api -n 50

# Follow logs in real-time
sudo journalctl -u telemetry-api -f
```

### Service Management Commands

```bash
# Stop the service
sudo systemctl stop telemetry-api

# Restart the service
sudo systemctl restart telemetry-api

# Disable auto-start
sudo systemctl disable telemetry-api
```

## Flutter Integration

### Add HTTP Package

Add the `http` package to your Flutter project:

```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
```

### Example Flutter Code

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TelemetryService {
  final String baseUrl;

  TelemetryService({required this.baseUrl});

  Future<Map<String, dynamic>> getTelemetry() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/telemetry'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load telemetry data');
      }
    } catch (e) {
      throw Exception('Error fetching telemetry: $e');
    }
  }

  Future<double?> getCpuTemperature() async {
    final data = await getTelemetry();
    return data['cpu']['temperature_celsius'];
  }

  Future<Map<String, dynamic>> getWifiSignal() async {
    final data = await getTelemetry();
    return data['wifi'];
  }
}

// Usage Example
void main() async {
  final telemetry = TelemetryService(
    baseUrl: 'http://192.168.1.100:8000', // Replace with your Pi's IP
  );

  try {
    final data = await telemetry.getTelemetry();
    print('CPU Temp: ${data['cpu']['temperature_celsius']}°C');
    print('Wi-Fi Signal: ${data['wifi']['signal_level_dbm']} dBm');
    print('Uptime: ${data['system']['uptime_hours']} hours');
    print('Memory Used: ${data['memory']['used_percent']}%');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Example Widget

```dart
class TelemetryWidget extends StatefulWidget {
  @override
  _TelemetryWidgetState createState() => _TelemetryWidgetState();
}

class _TelemetryWidgetState extends State<TelemetryWidget> {
  final telemetryService = TelemetryService(
    baseUrl: 'http://192.168.1.100:8000', // Your Pi's IP
  );
  Map<String, dynamic>? telemetryData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTelemetry();
  }

  Future<void> loadTelemetry() async {
    setState(() => isLoading = true);
    try {
      final data = await telemetryService.getTelemetry();
      setState(() {
        telemetryData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading telemetry: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (telemetryData == null) {
      return Center(child: Text('Failed to load data'));
    }

    return RefreshIndicator(
      onRefresh: loadTelemetry,
      child: ListView(
        children: [
          ListTile(
            title: Text('CPU Temperature'),
            trailing: Text(
              '${telemetryData!['cpu']['temperature_celsius']}°C',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text('Wi-Fi Signal'),
            trailing: Text(
              '${telemetryData!['wifi']['signal_level_dbm']} dBm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text('Uptime'),
            trailing: Text(
              '${telemetryData!['system']['uptime_hours']} hrs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text('Memory Used'),
            trailing: Text(
              '${telemetryData!['memory']['used_percent']}%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Troubleshooting

### API Not Accessible from Other Devices

1. **Check firewall settings:**
   ```bash
   sudo ufw allow 8000/tcp
   ```

2. **Verify the Pi's IP address:**
   ```bash
   hostname -I
   ```

3. **Ensure the API is listening on 0.0.0.0:**
   ```bash
   ss -tulpn | grep 8000
   ```

### Wi-Fi Signal Not Detected

The API tries two methods to read Wi-Fi signal:
1. `/proc/net/wireless` (primary)
2. `iwconfig` command (fallback)

If both fail, ensure your Wi-Fi interface is active:
```bash
iwconfig
```

### CPU Temperature Returns None

Verify the thermal zone file exists:
```bash
cat /sys/class/thermal/thermal_zone0/temp
```

### Service Won't Start

Check service logs:
```bash
sudo journalctl -u telemetry-api -n 50 --no-pager
```

Common issues:
- Wrong paths in service file
- Virtual environment not created
- Dependencies not installed
- Permission issues

## Development

### Running in Development Mode

For development with auto-reload:

```bash
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Testing Endpoints

Using `curl`:

```bash
# Test main telemetry endpoint
curl http://localhost:8000/telemetry

# Test CPU temperature
curl http://localhost:8000/telemetry/cpu

# Pretty-print JSON
curl http://localhost:8000/telemetry | python3 -m json.tool
```

Using browser:
- Visit `http://<pi-ip>:8000/docs` for interactive API testing

## Security Considerations

This initial implementation includes:
- ✅ CORS enabled for all origins
- ❌ No authentication
- ❌ No rate limiting
- ❌ HTTP only (no HTTPS)

### For Production Use:

1. **Add Authentication:**
   - Implement API key authentication
   - Use OAuth2 or JWT tokens

2. **Restrict CORS:**
   ```python
   allow_origins=["https://your-flutter-app.com"]
   ```

3. **Add Rate Limiting:**
   - Use middleware like `slowapi`

4. **Enable HTTPS:**
   - Use reverse proxy (Nginx) with SSL certificates
   - Let's Encrypt for free certificates

5. **Add Monitoring:**
   - Log API requests
   - Set up alerts for anomalies

## License

This project is open source. Feel free to use and modify as needed.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Author

Created for Raspberry Pi Zero 2 W home automation and monitoring.
