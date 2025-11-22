"""
Home Telemetry API for Raspberry Pi Zero 2 W
FastAPI server exposing system telemetry data as JSON endpoints.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from telemetry_readers import (
    get_all_telemetry,
    get_cpu_temperature,
    get_wifi_signal,
    get_wifi_signal_iwconfig,
    get_uptime,
    get_load_average,
    get_memory_info
)

# Initialize FastAPI app
app = FastAPI(
    title="Home Telemetry API",
    description="Raspberry Pi Zero 2 W system telemetry monitoring API",
    version="1.0.0"
)

# Configure CORS to allow Flutter apps to access the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins - restrict this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "name": "Home Telemetry API",
        "version": "1.0.0",
        "description": "Raspberry Pi system monitoring API",
        "endpoints": {
            "telemetry": "/telemetry - All telemetry data",
            "cpu": "/telemetry/cpu - CPU temperature",
            "wifi": "/telemetry/wifi - Wi-Fi signal strength",
            "system": "/telemetry/system - System uptime and load",
            "memory": "/telemetry/memory - Memory information",
            "docs": "/docs - API documentation"
        }
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "telemetry-api"
    }


@app.get("/telemetry")
async def get_telemetry():
    """
    Get all system telemetry data.
    
    Returns:
        JSON object containing CPU temperature, Wi-Fi signal,
        system uptime/load, and memory information.
    """
    try:
        telemetry_data = get_all_telemetry()
        return JSONResponse(content={
            "status": "success",
            "data": telemetry_data
        })
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": str(e)
            }
        )


@app.get("/telemetry/cpu")
async def get_cpu_telemetry():
    """
    Get CPU telemetry data.
    
    Returns:
        JSON object with CPU temperature in Celsius.
    """
    try:
        temp = get_cpu_temperature()
        return JSONResponse(content={
            "status": "success",
            "data": {
                "temperature_celsius": temp
            }
        })
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": str(e)
            }
        )


@app.get("/telemetry/wifi")
async def get_wifi_telemetry():
    """
    Get Wi-Fi telemetry data.
    
    Returns:
        JSON object with Wi-Fi signal level (dBm) and quality (%).
    """
    try:
        wifi_data = get_wifi_signal()
        if wifi_data["signal_level"] is None:
            # Try iwconfig as fallback
            wifi_data = get_wifi_signal_iwconfig()
        
        return JSONResponse(content={
            "status": "success",
            "data": {
                "signal_level_dbm": wifi_data["signal_level"],
                "signal_quality_percent": wifi_data["signal_quality"]
            }
        })
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": str(e)
            }
        )


@app.get("/telemetry/system")
async def get_system_telemetry():
    """
    Get system telemetry data.
    
    Returns:
        JSON object with uptime and load average.
    """
    try:
        uptime_data = get_uptime()
        load_data = get_load_average()
        
        return JSONResponse(content={
            "status": "success",
            "data": {
                "uptime_seconds": uptime_data["uptime_seconds"],
                "uptime_hours": round(uptime_data["uptime_seconds"] / 3600, 2),
                "load_average": load_data
            }
        })
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": str(e)
            }
        )


@app.get("/telemetry/memory")
async def get_memory_telemetry():
    """
    Get memory telemetry data.
    
    Returns:
        JSON object with memory statistics in MB.
    """
    try:
        memory_data = get_memory_info()
        
        return JSONResponse(content={
            "status": "success",
            "data": memory_data
        })
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": str(e)
            }
        )


if __name__ == "__main__":
    import uvicorn
    # Run with: python main.py
    # Or use: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    uvicorn.run(app, host="0.0.0.0", port=8000)
