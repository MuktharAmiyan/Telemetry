class TelemetryData {
  final CpuData cpu;
  final WifiData wifi;
  final SystemData system;
  final MemoryData memory;
  final DiskData disk;
  final NetworkData network;

  TelemetryData({
    required this.cpu,
    required this.wifi,
    required this.system,
    required this.memory,
    required this.disk,
    required this.network,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      cpu: CpuData.fromJson(json['cpu']),
      wifi: WifiData.fromJson(json['wifi']),
      system: SystemData.fromJson(json['system']),
      memory: MemoryData.fromJson(json['memory']),
      disk: DiskData.fromJson(json['disk']),
      network: NetworkData.fromJson(json['network']),
    );
  }
}

class CpuData {
  final double temperatureCelsius;
  final double usagePercent;

  CpuData({
    required this.temperatureCelsius,
    required this.usagePercent,
  });

  factory CpuData.fromJson(Map<String, dynamic> json) {
    return CpuData(
      temperatureCelsius: (json['temperature_celsius'] as num?)?.toDouble() ?? 0.0,
      usagePercent: (json['usage_percent'] as num?)?.toDouble() ?? 0.0,
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
      signalLevelDbm: json['signal_level_dbm'] as int? ?? 0,
      signalQualityPercent: (json['signal_quality_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SystemData {
  final double uptimeHours;
  final LoadAverage loadAverage;
  final SystemInfo info;
  final ThrottlingData throttling;

  SystemData({
    required this.uptimeHours,
    required this.loadAverage,
    required this.info,
    required this.throttling,
  });

  factory SystemData.fromJson(Map<String, dynamic> json) {
    return SystemData(
      uptimeHours: (json['uptime_hours'] as num?)?.toDouble() ?? 0.0,
      loadAverage: LoadAverage.fromJson(json['load_average']),
      info: SystemInfo.fromJson(json['info']),
      throttling: ThrottlingData.fromJson(json['throttling']),
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
      load1min: (json['load_1min'] as num?)?.toDouble() ?? 0.0,
      load5min: (json['load_5min'] as num?)?.toDouble() ?? 0.0,
      load15min: (json['load_15min'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SystemInfo {
  final String hostname;
  final String os;
  final String kernel;
  final String ipAddress;

  SystemInfo({
    required this.hostname,
    required this.os,
    required this.kernel,
    required this.ipAddress,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      hostname: json['hostname'] as String? ?? 'Unknown',
      os: json['os'] as String? ?? 'Unknown',
      kernel: json['kernel'] as String? ?? 'Unknown',
      ipAddress: json['ip_address'] as String? ?? 'Unknown',
    );
  }
}

class ThrottlingData {
  final bool isThrottled;
  final bool underVoltage;
  final bool frequencyCapped;
  final bool overheated;

  ThrottlingData({
    required this.isThrottled,
    required this.underVoltage,
    required this.frequencyCapped,
    required this.overheated,
  });

  factory ThrottlingData.fromJson(Map<String, dynamic> json) {
    return ThrottlingData(
      isThrottled: json['is_throttled'] as bool? ?? false,
      underVoltage: json['under_voltage'] as bool? ?? false,
      frequencyCapped: json['frequency_capped'] as bool? ?? false,
      overheated: json['overheated'] as bool? ?? false,
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
      totalMb: (json['total_mb'] as num?)?.toDouble() ?? 0.0,
      freeMb: (json['free_mb'] as num?)?.toDouble() ?? 0.0,
      availableMb: (json['available_mb'] as num?)?.toDouble() ?? 0.0,
      usedMb: (json['used_mb'] as num?)?.toDouble() ?? 0.0,
      usedPercent: (json['used_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DiskData {
  final double totalGb;
  final double usedGb;
  final double freeGb;
  final double percent;

  DiskData({
    required this.totalGb,
    required this.usedGb,
    required this.freeGb,
    required this.percent,
  });

  factory DiskData.fromJson(Map<String, dynamic> json) {
    return DiskData(
      totalGb: (json['total_gb'] as num?)?.toDouble() ?? 0.0,
      usedGb: (json['used_gb'] as num?)?.toDouble() ?? 0.0,
      freeGb: (json['free_gb'] as num?)?.toDouble() ?? 0.0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NetworkData {
  final String interface;
  final int bytesRecv;
  final int bytesSent;

  NetworkData({
    required this.interface,
    required this.bytesRecv,
    required this.bytesSent,
  });

  factory NetworkData.fromJson(Map<String, dynamic> json) {
    return NetworkData(
      interface: json['interface'] as String? ?? 'none',
      bytesRecv: json['bytes_recv'] as int? ?? 0,
      bytesSent: json['bytes_sent'] as int? ?? 0,
    );
  }
}
