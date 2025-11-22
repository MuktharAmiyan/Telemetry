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
  final TextEditingController _ipController = TextEditingController(text: 'http://localhost:8000');
  late TelemetryService _service;
  TelemetryData? _data;
  TelemetryData? _previousData; // For calculating network speed
  bool _isLoading = false;
  String? _error;
  Timer? _timer;


  @override
  void initState() {
    super.initState();
    _service = TelemetryService(baseUrl: _ipController.text);
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _loadData(silent: true));
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
          _previousData = _data;
          _data = data;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (!silent) _error = e.toString();
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

  Future<void> _reboot() async {
    final confirm = await _showConfirmation('Reboot System', 'Are you sure you want to reboot the Raspberry Pi?');
    if (confirm == true) {
      try {
        await _service.rebootSystem();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reboot command sent')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _shutdown() async {
    final confirm = await _showConfirmation('Shutdown System', 'Are you sure you want to shut down the Raspberry Pi?');
    if (confirm == true) {
      try {
        await _service.shutdownSystem();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shutdown command sent')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<bool?> _showConfirmation(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(content, style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Settings', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: _ipController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'API URL',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _updateUrl, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showControlPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Power Controls', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPowerButton('Reboot', Icons.restart_alt, Colors.orange, _reboot),
                _buildPowerButton('Shutdown', Icons.power_settings_new, Colors.red, _shutdown),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  String _getNetworkSpeed(int currentBytes, int previousBytes) {
    if (_previousData == null) return '0 KB/s';
    final diff = currentBytes - previousBytes;
    // Assuming 2 second interval roughly
    final bytesPerSec = diff / 2; 
    if (bytesPerSec > 1024 * 1024) return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Telemetry', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
            if (_data != null)
              Text(
                '${_data!.system.info.hostname} • ${_data!.system.info.ipAddress}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
              ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.power_settings_new, color: Colors.redAccent), onPressed: _showControlPanel),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: _showSettingsDialog),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) return const Center(child: CircularProgressIndicator());
    if (_error != null && _data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Connection Failed', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.grey[400]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => _loadData(), child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_data == null) return const Center(child: Text('No Data'));

    final d = _data!;
    final prev = _previousData ?? d;

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
            value: d.cpu.temperatureCelsius.toStringAsFixed(1),
            unit: '°C',
            icon: Icons.thermostat,
            color: _getCpuColor(d.cpu.temperatureCelsius),
            progress: (d.cpu.temperatureCelsius / 85).clamp(0.0, 1.0),
          ),
          TelemetryCard(
            title: 'CPU Usage',
            value: d.cpu.usagePercent.toStringAsFixed(1),
            unit: '%',
            icon: Icons.speed,
            color: _getUsageColor(d.cpu.usagePercent),
            progress: d.cpu.usagePercent / 100,
          ),
          TelemetryCard(
            title: 'Memory Used',
            value: d.memory.usedPercent.toStringAsFixed(1),
            unit: '%',
            icon: Icons.memory,
            color: _getUsageColor(d.memory.usedPercent),
            progress: d.memory.usedPercent / 100,
          ),
          TelemetryCard(
            title: 'Disk Usage',
            value: d.disk.percent.toStringAsFixed(1),
            unit: '%',
            icon: Icons.storage,
            color: _getUsageColor(d.disk.percent),
            progress: d.disk.percent / 100,
            trailing: Text('${d.disk.freeGb.toStringAsFixed(1)} GB Free', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ),
          TelemetryCard(
            title: 'Wi-Fi Signal',
            value: d.wifi.signalLevelDbm.toString(),
            unit: 'dBm',
            icon: Icons.wifi,
            color: _getWifiColor(d.wifi.signalLevelDbm),
            progress: d.wifi.signalQualityPercent / 100,
          ),
          TelemetryCard(
            title: 'Network Down',
            value: _getNetworkSpeed(d.network.bytesRecv, prev.network.bytesRecv).split(' ')[0],
            unit: _getNetworkSpeed(d.network.bytesRecv, prev.network.bytesRecv).split(' ')[1],
            icon: Icons.download,
            color: Colors.blue,
          ),
          TelemetryCard(
            title: 'Uptime',
            value: d.system.uptimeHours.toStringAsFixed(1),
            unit: 'hrs',
            icon: Icons.timer,
            color: Colors.teal,
          ),
          TelemetryCard(
            title: 'System Health',
            value: d.system.throttling.isThrottled ? 'Issues' : 'Good',
            unit: '',
            icon: d.system.throttling.isThrottled ? Icons.warning : Icons.check_circle,
            color: d.system.throttling.isThrottled ? Colors.red : Colors.green,
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

  Color _getUsageColor(double percent) {
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
