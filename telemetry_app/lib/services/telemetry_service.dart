import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nsd/nsd.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/telemetry_data.dart';

class TelemetryService {
  final String baseUrl;

  TelemetryService({required this.baseUrl});

  Future<TelemetryData> getTelemetry() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/telemetry'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return TelemetryData.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
            'API returned error status: ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load telemetry data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching telemetry: $e');
    }
  }

  Stream<TelemetryData> getTelemetryStream() {
    // Convert http://... to ws://...
    final wsUrl = baseUrl.replaceFirst('http', 'ws') + '/ws';
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    return channel.stream.map((event) {
      final jsonResponse = json.decode(event);
      // The WS endpoint sends the data object directly, not wrapped in {status: success, data: ...}
      // Wait, let's check main.py. It sends `data = telemetry_readers.get_all_telemetry()`.
      // So it is the raw data object.
      return TelemetryData.fromJson(jsonResponse);
    });
  }

  Future<void> rebootSystem() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/control/reboot'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Failed to reboot: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending reboot command: $e');
    }
  }

  Future<void> shutdownSystem() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/control/shutdown'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Failed to shutdown: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending shutdown command: $e');
    }
  }

  static Future<List<Service>> findDevices() async {
    try {
      final discovery = await startDiscovery('_http._tcp');
      await Future.delayed(const Duration(seconds: 4));
      await stopDiscovery(discovery);
      return discovery.services;
    } catch (e) {
      print('Error discovering devices: $e');
      return [];
    }
  }
}
