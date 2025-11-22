import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/telemetry_data.dart';

class TelemetryService {
  final String baseUrl;

  TelemetryService({required this.baseUrl});

  Future<TelemetryData> getTelemetry() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/telemetry'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return TelemetryData.fromJson(jsonResponse['data']);
        } else {
          throw Exception('API returned error status: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load telemetry data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching telemetry: $e');
    }
  }

  Future<void> rebootSystem() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/control/reboot'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Failed to reboot: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending reboot command: $e');
    }
  }

  Future<void> shutdownSystem() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/control/shutdown'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Failed to shutdown: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending shutdown command: $e');
    }
  }
}
