class TelemetryData {
  final CpuData cpu;
  final WifiData wifi;
  final SystemData system;
  final MemoryData memory;

  TelemetryData({
    required this.cpu,
    required this.wifi,
    required this.system,
    required this.memory,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      cpu: CpuData.fromJson(json['cpu']),
      wifi: WifiData.fromJson(json['wifi']),
      system: SystemData.fromJson(json['system']),
      memory: MemoryData.fromJson(json['memory']),
    );
  }
}

class CpuData {
  final double temperatureCelsius;

  CpuData({required this.temperatureCelsius});

  factory CpuData.fromJson(Map<String, dynamic> json) {
    return CpuData(
      temperatureCelsius: (json['temperature_celsius'] as num).toDouble(),
    );
  }
}

class WifiData {
  final int signalLevelDbm;
  final double signalQualityPercent;

  WifiData({
    required this.signalLevelDbm,
    required this.signalQualityPercent,
  });

  factory WifiData.fromJson(Map<String, dynamic> json) {
    return WifiData(
      signalLevelDbm: json['signal_level_dbm'] as int,
      signalQualityPercent: (json['signal_quality_percent'] as num).toDouble(),
    );
  }
}

class SystemData {
  final double uptimeHours;
  final LoadAverage loadAverage;

  SystemData({
    required this.uptimeHours,
    required this.loadAverage,
  });

  factory SystemData.fromJson(Map<String, dynamic> json) {
    return SystemData(
      uptimeHours: (json['uptime_hours'] as num).toDouble(),
      loadAverage: LoadAverage.fromJson(json['load_average']),
    );
  }
}

class LoadAverage {
  final double load1min;
  final double load5min;
  final double load15min;

  LoadAverage({
    required this.load1min,
    required this.load5min,
    required this.load15min,
  });

  factory LoadAverage.fromJson(Map<String, dynamic> json) {
    return LoadAverage(
      load1min: (json['load_1min'] as num).toDouble(),
      load5min: (json['load_5min'] as num).toDouble(),
      load15min: (json['load_15min'] as num).toDouble(),
    );
  }
}

class MemoryData {
  final double totalMb;
  final double freeMb;
  final double availableMb;
  final double usedMb;
  final double usedPercent;

  MemoryData({
    required this.totalMb,
    required this.freeMb,
    required this.availableMb,
    required this.usedMb,
    required this.usedPercent,
  });

  factory MemoryData.fromJson(Map<String, dynamic> json) {
    return MemoryData(
      totalMb: (json['total_mb'] as num).toDouble(),
      freeMb: (json['free_mb'] as num).toDouble(),
      availableMb: (json['available_mb'] as num).toDouble(),
      usedMb: (json['used_mb'] as num).toDouble(),
      usedPercent: (json['used_percent'] as num).toDouble(),
    );
  }
}
