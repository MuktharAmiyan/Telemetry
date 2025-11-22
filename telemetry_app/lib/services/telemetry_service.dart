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
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load telemetry data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching telemetry: $e');
    }
  }
}
