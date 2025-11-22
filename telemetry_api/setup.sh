#!/bin/bash

# Home Telemetry API Setup Script for Raspberry Pi Zero 2 W
# This script sets up the Python virtual environment and installs dependencies

echo "========================================="
echo "Home Telemetry API - Setup Script"
echo "========================================="
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Setting up in directory: $SCRIPT_DIR"
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed."
    echo "Please install Python 3: sudo apt install python3 python3-venv python3-pip"
    exit 1
fi

echo "Python 3 found: $(python3 --version)"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo "Virtual environment created."
else
    echo "Virtual environment already exists."
fi
echo ""

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo ""
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

echo ""
echo "========================================="
echo "Setup complete!"
echo "========================================="
echo ""
echo "To start the API manually:"
echo "  1. Activate the virtual environment:"
echo "     source venv/bin/activate"
echo ""
echo "  2. Run the API:"
echo "     uvicorn main:app --host 0.0.0.0 --port 8000"
echo ""
echo "  Or simply run:"
echo "     python main.py"
echo ""
echo "To set up as a system service:"
echo "  1. Copy the service file:"
echo "     sudo cp telemetry-api.service /etc/systemd/system/"
echo ""
echo "  2. Update the WorkingDirectory and ExecStart paths in the service file"
echo "     to match your installation directory:"
echo "     sudo nano /etc/systemd/system/telemetry-api.service"
echo ""
echo "  3. Reload systemd and enable the service:"
echo "     sudo systemctl daemon-reload"
echo "     sudo systemctl enable telemetry-api"
echo "     sudo systemctl start telemetry-api"
echo ""
echo "  4. Check service status:"
echo "     sudo systemctl status telemetry-api"
echo ""
echo "Access the API at: http://<your-pi-ip>:8000"
echo "API Documentation: http://<your-pi-ip>:8000/docs"
echo ""
