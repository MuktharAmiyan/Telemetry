"""
Telemetry reader functions for Raspberry Pi system monitoring.
Reads CPU temperature, Wi-Fi signal, system uptime, memory, disk usage, and more.
"""

import os
import subprocess
import socket
import platform
import time
from typing import Dict, Optional, Tuple


def get_cpu_temperature() -> Optional[float]:
    """
    Read CPU temperature from thermal zone.
    
    Returns:
        Temperature in Celsius, or None if unavailable.
    """
    temp_file = "/sys/class/thermal/thermal_zone0/temp"
    try:
        if os.path.exists(temp_file):
            with open(temp_file, 'r') as f:
                # Temperature is in millidegrees Celsius
                temp_millidegrees = int(f.read().strip())
                return temp_millidegrees / 1000.0
        return None
    except (FileNotFoundError, ValueError, PermissionError) as e:
        print(f"Error reading CPU temperature: {e}")
        return None


def get_wifi_signal() -> Dict[str, Optional[float]]:
    """
    Get Wi-Fi signal strength and quality from /proc/net/wireless.
    
    Returns:
        Dictionary with 'signal_level' (dBm) and 'signal_quality' (%).
    """
    wireless_file = "/proc/net/wireless"
    result = {
        "signal_level": None,
        "signal_quality": None
    }
    
    try:
        if os.path.exists(wireless_file):
            with open(wireless_file, 'r') as f:
                lines = f.readlines()
                # Skip the first two header lines
                if len(lines) > 2:
                    # Third line contains the data
                    data_line = lines[2].split()
                    if len(data_line) >= 4:
                        # Format: interface | status | quality | discarded | missed | WE
                        # Quality is usually: link quality . signal level . noise level
                        quality_str = data_line[2].rstrip('.')
                        signal_str = data_line[3].rstrip('.')
                        
                        # Quality is out of 70 typically
                        quality = int(quality_str)
                        result["signal_quality"] = round((quality / 70.0) * 100, 2)
                        
                        # Signal level is in dBm (negative value)
                        result["signal_level"] = int(signal_str)
        
        return result
    except (FileNotFoundError, ValueError, IndexError, PermissionError) as e:
        print(f"Error reading Wi-Fi signal: {e}")
        return result


def get_wifi_signal_iwconfig() -> Dict[str, Optional[float]]:
    """
    Alternative method: Get Wi-Fi signal using iwconfig command.
    Fallback if /proc/net/wireless parsing fails.
    
    Returns:
        Dictionary with 'signal_level' (dBm) and 'signal_quality' (%).
    """
    result = {
        "signal_level": None,
        "signal_quality": None
    }
    
    try:
        # Run iwconfig to get wireless info
        output = subprocess.check_output(['iwconfig'], stderr=subprocess.DEVNULL, text=True)
        
        # Parse the output for signal level
        for line in output.split('\n'):
            if 'Signal level' in line or 'Link Quality' in line:
                # Example: Link Quality=60/70  Signal level=-50 dBm
                if 'Link Quality' in line:
                    parts = line.split('Link Quality=')
                    if len(parts) > 1:
                        quality_part = parts[1].split()[0]
                        if '/' in quality_part:
                            current, maximum = quality_part.split('/')
                            result["signal_quality"] = round((int(current) / int(maximum)) * 100, 2)
                
                if 'Signal level' in line:
                    parts = line.split('Signal level=')
                    if len(parts) > 1:
                        signal = parts[1].split()[0]
                        result["signal_level"] = int(signal)
        
        return result
    except (subprocess.CalledProcessError, FileNotFoundError, ValueError) as e:
        print(f"Error reading Wi-Fi signal with iwconfig: {e}")
        return result


def get_uptime() -> Dict[str, float]:
    """
    Read system uptime from /proc/uptime.
    
    Returns:
        Dictionary with 'uptime_seconds' and 'idle_seconds'.
    """
    uptime_file = "/proc/uptime"
    result = {
        "uptime_seconds": 0.0,
        "idle_seconds": 0.0
    }
    
    try:
        if os.path.exists(uptime_file):
            with open(uptime_file, 'r') as f:
                line = f.read().strip()
                parts = line.split()
                if len(parts) >= 2:
                    result["uptime_seconds"] = float(parts[0])
                    result["idle_seconds"] = float(parts[1])
        
        return result
    except (FileNotFoundError, ValueError, PermissionError) as e:
        print(f"Error reading uptime: {e}")
        return result


def get_load_average() -> Dict[str, float]:
    """
    Get system load average.
    
    Returns:
        Dictionary with '1min', '5min', and '15min' load averages.
    """
    try:
        load_avg = os.getloadavg()
        return {
            "load_1min": round(load_avg[0], 2),
            "load_5min": round(load_avg[1], 2),
            "load_15min": round(load_avg[2], 2)
        }
    except (OSError, AttributeError) as e:
        print(f"Error reading load average: {e}")
        return {
            "load_1min": 0.0,
            "load_5min": 0.0,
            "load_15min": 0.0
        }


def get_memory_info() -> Dict[str, float]:
    """
    Read memory information from /proc/meminfo.
    
    Returns:
        Dictionary with memory stats in MB.
    """
    meminfo_file = "/proc/meminfo"
    result = {
        "total_mb": 0.0,
        "free_mb": 0.0,
        "available_mb": 0.0,
        "used_mb": 0.0,
        "used_percent": 0.0
    }
    
    try:
        if os.path.exists(meminfo_file):
            mem_data = {}
            with open(meminfo_file, 'r') as f:
                for line in f:
                    parts = line.split(':')
                    if len(parts) == 2:
                        key = parts[0].strip()
                        # Remove 'kB' and convert to int
                        value = int(parts[1].strip().split()[0])
                        mem_data[key] = value
            
            # Convert from kB to MB
            if 'MemTotal' in mem_data:
                result["total_mb"] = round(mem_data['MemTotal'] / 1024, 2)
            if 'MemFree' in mem_data:
                result["free_mb"] = round(mem_data['MemFree'] / 1024, 2)
            if 'MemAvailable' in mem_data:
                result["available_mb"] = round(mem_data['MemAvailable'] / 1024, 2)
            
            # Calculate used memory
            if result["total_mb"] > 0 and result["available_mb"] > 0:
                result["used_mb"] = round(result["total_mb"] - result["available_mb"], 2)
                result["used_percent"] = round((result["used_mb"] / result["total_mb"]) * 100, 2)
        
        return result
    except (FileNotFoundError, ValueError, PermissionError) as e:
        print(f"Error reading memory info: {e}")
        return result


def get_disk_usage() -> Dict[str, float]:
    """
    Get disk usage statistics for the root partition.
    
    Returns:
        Dictionary with total, used, free (in GB) and percent used.
    """
    try:
        stat = os.statvfs('/')
        total = stat.f_blocks * stat.f_frsize
        free = stat.f_bavail * stat.f_frsize
        used = total - free
        
        total_gb = total / (1024 ** 3)
        used_gb = used / (1024 ** 3)
        free_gb = free / (1024 ** 3)
        percent = (used / total) * 100 if total > 0 else 0
        
        return {
            "total_gb": round(total_gb, 2),
            "used_gb": round(used_gb, 2),
            "free_gb": round(free_gb, 2),
            "percent": round(percent, 1)
        }
    except OSError as e:
        print(f"Error reading disk usage: {e}")
        return {"total_gb": 0.0, "used_gb": 0.0, "free_gb": 0.0, "percent": 0.0}


def get_system_info() -> Dict[str, str]:
    """
    Get static system information.
    
    Returns:
        Dictionary with hostname, os, kernel, and ip.
    """
    try:
        hostname = socket.gethostname()
        
        # Get IP address (try to find a non-localhost one)
        ip_address = "127.0.0.1"
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            # Doesn't need to be reachable
            s.connect(('10.255.255.255', 1))
            ip_address = s.getsockname()[0]
            s.close()
        except Exception:
            pass

        return {
            "hostname": hostname,
            "os": f"{platform.system()} {platform.release()}",
            "kernel": platform.version(),
            "ip_address": ip_address
        }
    except Exception as e:
        print(f"Error getting system info: {e}")
        return {"hostname": "Unknown", "os": "Unknown", "kernel": "Unknown", "ip_address": "Unknown"}


def get_cpu_usage() -> float:
    """
    Calculate CPU usage percentage.
    Note: This is a blocking call for a short duration (0.1s) to calculate diff.
    For a production API, this might be better handled in a background thread or 
    by reading /proc/stat and storing state. For simplicity here, we block briefly.
    
    Returns:
        CPU usage percentage (0.0 to 100.0)
    """
    try:
        # First read
        with open('/proc/stat', 'r') as f:
            line1 = f.readline()
        
        time.sleep(0.1)
        
        # Second read
        with open('/proc/stat', 'r') as f:
            line2 = f.readline()
            
        def parse_stat(line):
            parts = line.split()
            # parts[0] is 'cpu'
            # parts[1-7] are user, nice, system, idle, iowait, irq, softirq
            if len(parts) < 5: return 0, 0
            total = sum(int(x) for x in parts[1:])
            idle = int(parts[4])
            return total, idle
            
        total1, idle1 = parse_stat(line1)
        total2, idle2 = parse_stat(line2)
        
        diff_total = total2 - total1
        diff_idle = idle2 - idle1
        
        if diff_total == 0: return 0.0
        
        usage = ((diff_total - diff_idle) / diff_total) * 100
        return round(usage, 1)
        
    except Exception as e:
        print(f"Error reading CPU usage: {e}")
        return 0.0


def get_throttling_status() -> Dict[str, bool]:
    """
    Check for throttling (under-voltage, frequency capping) using vcgencmd.
    
    Returns:
        Dictionary with boolean flags for different throttling states.
    """
    result = {
        "is_throttled": False,
        "under_voltage": False,
        "frequency_capped": False,
        "overheated": False
    }
    
    try:
        # vcgencmd get_throttled returns hex, e.g., throttled=0x50000
        output = subprocess.check_output(['vcgencmd', 'get_throttled'], stderr=subprocess.DEVNULL, text=True)
        if '=' in output:
            hex_str = output.split('=')[1].strip()
            status = int(hex_str, 16)
            
            # Bit definitions from Raspberry Pi documentation
            result["under_voltage"] = bool(status & 0x1)
            result["frequency_capped"] = bool(status & 0x2)
            result["overheated"] = bool(status & 0x4)
            result["is_throttled"] = status > 0
            
        return result
    except (subprocess.CalledProcessError, FileNotFoundError):
        # vcgencmd might not be available on non-Pi systems
        return result


def get_network_stats() -> Dict[str, int]:
    """
    Get network statistics (bytes sent/received).
    
    Returns:
        Dictionary with bytes_sent and bytes_recv.
    """
    try:
        # Try to find the main interface (usually wlan0 or eth0)
        interfaces = ['wlan0', 'eth0', 'en0'] # en0 for mac testing
        target_iface = None
        
        with open('/proc/net/dev', 'r') as f:
            lines = f.readlines()
            
        for line in lines[2:]:
            iface = line.split(':')[0].strip()
            if iface in interfaces:
                target_iface = iface
                data = line.split(':')[1].split()
                return {
                    "interface": iface,
                    "bytes_recv": int(data[0]),
                    "bytes_sent": int(data[8])
                }
        
        # If no specific interface found, just return the first non-lo one
        for line in lines[2:]:
            iface = line.split(':')[0].strip()
            if iface != 'lo':
                data = line.split(':')[1].split()
                return {
                    "interface": iface,
                    "bytes_recv": int(data[0]),
                    "bytes_sent": int(data[8])
                }
                
        return {"interface": "none", "bytes_recv": 0, "bytes_sent": 0}
        
    except (FileNotFoundError, IndexError, ValueError):
        return {"interface": "none", "bytes_recv": 0, "bytes_sent": 0}


def get_all_telemetry() -> Dict:
    """
    Collect all telemetry data.
    
    Returns:
        Dictionary containing all system telemetry information.
    """
    # Get Wi-Fi signal with fallback
    wifi_data = get_wifi_signal()
    if wifi_data["signal_level"] is None:
        # Try iwconfig as fallback
        wifi_data = get_wifi_signal_iwconfig()
    
    uptime_data = get_uptime()
    memory_data = get_memory_info()
    load_data = get_load_average()
    disk_data = get_disk_usage()
    system_info = get_system_info()
    cpu_usage = get_cpu_usage()
    throttling = get_throttling_status()
    network = get_network_stats()
    
    return {
        "cpu": {
            "temperature_celsius": get_cpu_temperature(),
            "usage_percent": cpu_usage,
        },
        "wifi": {
            "signal_level_dbm": wifi_data["signal_level"],
            "signal_quality_percent": wifi_data["signal_quality"],
        },
        "system": {
            "uptime_seconds": uptime_data["uptime_seconds"],
            "uptime_hours": round(uptime_data["uptime_seconds"] / 3600, 2),
            "load_average": load_data,
            "info": system_info,
            "throttling": throttling,
        },
        "memory": memory_data,
        "disk": disk_data,
        "network": network,
    }
