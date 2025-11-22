from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Optional, Union
import subprocess
import platform
import telemetry_readers

app = FastAPI(
    title="Home Telemetry API",
    description="API for Raspberry Pi system monitoring and control",
    version="1.1.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Data Models ---

class CpuData(BaseModel):
    temperature_celsius: Optional[float]
    usage_percent: float

class WifiData(BaseModel):
    signal_level_dbm: Optional[int]
    signal_quality_percent: Optional[float]

class LoadAverage(BaseModel):
    load_1min: float
    load_5min: float
    load_15min: float

class ThrottlingData(BaseModel):
    is_throttled: bool
    under_voltage: bool
    frequency_capped: bool
    overheated: bool

class SystemInfo(BaseModel):
    hostname: str
    os: str
    kernel: str
    ip_address: str

class SystemData(BaseModel):
    uptime_seconds: float
    uptime_hours: float
    load_average: LoadAverage
    info: SystemInfo
    throttling: ThrottlingData

class MemoryData(BaseModel):
    total_mb: float
    free_mb: float
    available_mb: float
    used_mb: float
    used_percent: float

class DiskData(BaseModel):
    total_gb: float
    used_gb: float
    free_gb: float
    percent: float

class NetworkData(BaseModel):
    interface: str
    bytes_recv: int
    bytes_sent: int

class TelemetryResponse(BaseModel):
    cpu: CpuData
    wifi: WifiData
    system: SystemData
    memory: MemoryData
    disk: DiskData
    network: NetworkData

class ApiResponse(BaseModel):
    status: str
    data: Optional[TelemetryResponse] = None
    message: Optional[str] = None

# --- Endpoints ---

@app.get("/", tags=["General"])
async def root():
    return {
        "name": "Home Telemetry API",
        "version": "1.1.0",
        "description": "Raspberry Pi system monitoring API",
        "endpoints": {
            "/telemetry": "Get all telemetry data",
            "/telemetry/cpu": "Get CPU data",
            "/telemetry/memory": "Get memory data",
            "/telemetry/disk": "Get disk usage",
            "/telemetry/network": "Get network stats",
            "/control/reboot": "Reboot the system (POST)",
            "/control/shutdown": "Shutdown the system (POST)"
        }
    }

@app.get("/health", tags=["General"])
async def health_check():
    return {"status": "healthy", "service": "telemetry-api"}

@app.get("/telemetry", response_model=ApiResponse, tags=["Telemetry"])
async def get_telemetry():
    try:
        data = telemetry_readers.get_all_telemetry()
        return {"status": "success", "data": data}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/telemetry/cpu", tags=["Telemetry"])
async def get_cpu():
    return {
        "temperature_celsius": telemetry_readers.get_cpu_temperature(),
        "usage_percent": telemetry_readers.get_cpu_usage()
    }

@app.get("/telemetry/memory", tags=["Telemetry"])
async def get_memory():
    return telemetry_readers.get_memory_info()

@app.get("/telemetry/disk", tags=["Telemetry"])
async def get_disk():
    return telemetry_readers.get_disk_usage()

@app.get("/telemetry/network", tags=["Telemetry"])
async def get_network():
    return telemetry_readers.get_network_stats()

@app.post("/control/reboot", tags=["Control"])
async def reboot_system():
    # Check if running on Linux (Raspberry Pi)
    if platform.system() != "Linux":
        return {"status": "success", "message": "Simulated reboot (not on Linux)"}

    try:
        # This requires sudo privileges without password for the user running the service
        # Using full path to sudo for safety
        subprocess.run(["/usr/bin/sudo", "reboot"], check=True)
        return {"status": "success", "message": "System is rebooting..."}
    except FileNotFoundError:
        # Fallback if /usr/bin/sudo is not found, try just 'sudo'
        try:
            subprocess.run(["sudo", "reboot"], check=True)
            return {"status": "success", "message": "System is rebooting..."}
        except FileNotFoundError:
             raise HTTPException(status_code=500, detail="Command 'sudo' not found. Cannot reboot.")
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Failed to reboot: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/control/shutdown", tags=["Control"])
async def shutdown_system():
    # Check if running on Linux (Raspberry Pi)
    if platform.system() != "Linux":
        return {"status": "success", "message": "Simulated shutdown (not on Linux)"}

    try:
        # This requires sudo privileges without password for the user running the service
        subprocess.run(["/usr/bin/sudo", "shutdown", "-h", "now"], check=True)
        return {"status": "success", "message": "System is shutting down..."}
    except FileNotFoundError:
        # Fallback
        try:
            subprocess.run(["sudo", "shutdown", "-h", "now"], check=True)
            return {"status": "success", "message": "System is shutting down..."}
        except FileNotFoundError:
             raise HTTPException(status_code=500, detail="Command 'sudo' not found. Cannot shutdown.")
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Failed to shutdown: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
