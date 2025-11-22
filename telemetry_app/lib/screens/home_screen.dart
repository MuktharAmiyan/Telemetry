import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/telemetry_data.dart';
import '../services/telemetry_service.dart';
import '../widgets/telemetry_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Default to localhost for testing, user can change this
  final TextEditingController _ipController = TextEditingController(text: 'http://localhost:8000');
  late TelemetryService _service;
  TelemetryData? _data;
  bool _isLoading = false;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _service = TelemetryService(baseUrl: _ipController.text);
    _loadData();
    // Auto-refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadData(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _service.getTelemetry();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateUrl() {
    _service = TelemetryService(baseUrl: _ipController.text);
    _loadData();
    Navigator.pop(context);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Settings', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ipController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'API URL',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _updateUrl,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'System Telemetry',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Connection Failed',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_data == null) {
      return const Center(child: Text('No Data'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          TelemetryCard(
            title: 'CPU Temp',
            value: _data!.cpu.temperatureCelsius.toStringAsFixed(1),
            unit: '°C',
            icon: Icons.thermostat,
            color: _getCpuColor(_data!.cpu.temperatureCelsius),
            progress: (_data!.cpu.temperatureCelsius / 85).clamp(0.0, 1.0),
          ),
          TelemetryCard(
            title: 'Memory Used',
            value: _data!.memory.usedPercent.toStringAsFixed(1),
            unit: '%',
            icon: Icons.memory,
            color: _getMemoryColor(_data!.memory.usedPercent),
            progress: _data!.memory.usedPercent / 100,
          ),
          TelemetryCard(
            title: 'Wi-Fi Signal',
            value: _data!.wifi.signalLevelDbm.toString(),
            unit: 'dBm',
            icon: Icons.wifi,
            color: _getWifiColor(_data!.wifi.signalLevelDbm),
            progress: _data!.wifi.signalQualityPercent / 100,
          ),
          TelemetryCard(
            title: 'Uptime',
            value: _data!.system.uptimeHours.toStringAsFixed(1),
            unit: 'hrs',
            icon: Icons.timer,
            color: Colors.blue,
          ),
          TelemetryCard(
            title: 'Load (1m)',
            value: _data!.system.loadAverage.load1min.toStringAsFixed(2),
            icon: Icons.speed,
            color: Colors.orange,
          ),
          TelemetryCard(
            title: 'Free Memory',
            value: _data!.memory.freeMb.toStringAsFixed(0),
            unit: 'MB',
            icon: Icons.storage,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Color _getCpuColor(double temp) {
    if (temp < 50) return Colors.green;
    if (temp < 70) return Colors.orange;
    return Colors.red;
  }

  Color _getMemoryColor(double percent) {
    if (percent < 60) return Colors.green;
    if (percent < 85) return Colors.orange;
    return Colors.red;
  }

  Color _getWifiColor(int dbm) {
    if (dbm > -60) return Colors.green;
    if (dbm > -75) return Colors.orange;
    return Colors.red;
  }
}
