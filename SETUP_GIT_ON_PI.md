# Setting Up Git on Raspberry Pi

This guide will help you set up Git on your Raspberry Pi and pull the Telemetry code from your repository.

## Step 1: Install Git on Raspberry Pi

SSH into your Raspberry Pi and run:

```bash
sudo apt update
sudo apt install git -y
```

Verify the installation:

```bash
git --version
```

## Step 2: Configure Git

Set up your Git identity (replace with your actual name and email):

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Step 3: Create a Directory for Your Project

```bash
cd ~
mkdir -p projects
cd projects
```

## Step 4: Clone Only the API Folder (Sparse Checkout)

Since you only need the `telemetry_api` folder on your Raspberry Pi, we'll use Git sparse checkout to clone only that directory.

### Option A: Public Repository

```bash
# Create a directory for the project
mkdir Telemetry
cd Telemetry

# Initialize git repository
git init

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/Telemetry.git

# Enable sparse checkout
git config core.sparseCheckout true

# Specify which folder to checkout
echo "telemetry_api/*" >> .git/info/sparse-checkout

# Pull only the specified folder
git pull origin main
```

### Option B: Private Repository (Using Personal Access Token)

You'll need to authenticate. The easiest method is using a Personal Access Token (PAT):

1. **Generate a Personal Access Token on GitHub:**
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Give it a name (e.g., "Raspberry Pi")
   - Select scopes: `repo` (full control of private repositories)
   - Click "Generate token"
   - **Copy the token immediately** (you won't see it again)

2. **Clone using sparse checkout with token:**
   ```bash
   # Create a directory for the project
   mkdir Telemetry
   cd Telemetry

   # Initialize git repository
   git init

   # Add remote repository with token
   git remote add origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/Telemetry.git

   # Enable sparse checkout
   git config core.sparseCheckout true

   # Specify which folder to checkout
   echo "telemetry_api/*" >> .git/info/sparse-checkout

   # Pull only the specified folder
   git pull origin main
   ```

### Option C: Using SSH Keys (Recommended for frequent use)

1. **Generate SSH key on Raspberry Pi:**
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```
   Press Enter to accept default location, optionally set a passphrase.

2. **Copy the public key:**
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. **Add the key to GitHub:**
   - Go to GitHub → Settings → SSH and GPG keys → New SSH key
   - Paste the public key
   - Give it a title (e.g., "Raspberry Pi Zero 2 W")

4. **Clone using sparse checkout with SSH:**
   ```bash
   # Create a directory for the project
   mkdir Telemetry
   cd Telemetry

   # Initialize git repository
   git init

   # Add remote repository
   git remote add origin git@github.com:YOUR_USERNAME/Telemetry.git

   # Enable sparse checkout
   git config core.sparseCheckout true

   # Specify which folder to checkout
   echo "telemetry_api/*" >> .git/info/sparse-checkout

   # Pull only the specified folder
   git pull origin main
   ```

> **Note:** After this setup, you'll only have the `telemetry_api` folder on your Pi, saving space and avoiding unnecessary Flutter code.

## Step 5: Pull Latest Changes (Future Updates)

Whenever you want to update the code on your Pi:

```bash
cd ~/projects/Telemetry
git pull origin main
```

> **Note:** Replace `main` with your default branch name if different (e.g., `master`)

## Step 6: Set Up the Telemetry API on Pi

After cloning, navigate to the API directory and set up:

```bash
cd ~/projects/Telemetry/telemetry_api
```

### Install Python dependencies:

```bash
# Install pip if not already installed
sudo apt install python3-pip -y

# Install required packages
pip3 install fastapi uvicorn psutil
```

### Set up the systemd service:

```bash
# Copy the service file to systemd directory
sudo cp telemetry-api.service /etc/systemd/system/

# Edit the service file to ensure correct paths
sudo nano /etc/systemd/system/telemetry-api.service
```

Make sure the paths in the service file match your setup:
- `WorkingDirectory=/home/pi/projects/Telemetry/telemetry_api`
- `ExecStart=/usr/bin/python3 /home/pi/projects/Telemetry/telemetry_api/main.py`

### Enable and start the service:

```bash
# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable telemetry-api.service

# Start the service
sudo systemctl start telemetry-api.service

# Check the status
sudo systemctl status telemetry-api.service
```

## Step 7: Verify the API is Running

Check if the API is accessible:

```bash
curl http://localhost:8000/telemetry
```

You should see JSON output with telemetry data.

## Useful Git Commands

### Check current status:
```bash
git status
```

### View commit history:
```bash
git log --oneline
```

### Discard local changes and pull fresh:
```bash
git reset --hard origin/main
git pull
```

### Create a new branch (if you want to test changes):
```bash
git checkout -b test-branch
```

### Switch back to main branch:
```bash
git checkout main
```

## Troubleshooting

### Permission denied (publickey)
If you get this error with SSH, make sure:
- Your SSH key is added to GitHub
- The SSH agent is running: `eval "$(ssh-agent -s)"`
- Your key is added: `ssh-add ~/.ssh/id_ed25519`

### Authentication failed
If using HTTPS with a token:
- Make sure the token has the correct permissions
- The token hasn't expired
- You're using the correct format: `https://TOKEN@github.com/username/repo.git`

### Service fails to start
Check the logs:
```bash
sudo journalctl -u telemetry-api.service -f
```

Common issues:
- Python packages not installed
- Incorrect file paths in service file
- Port 8000 already in use

## Automatic Updates (Optional)

To automatically pull updates, you can create a cron job:

```bash
crontab -e
```

Add this line to pull updates daily at 3 AM:
```
0 3 * * * cd ~/projects/Telemetry && git pull origin main && sudo systemctl restart telemetry-api.service
```

---

## Quick Reference

```bash
# Update code from repository
cd ~/projects/Telemetry && git pull

# Restart the API service
sudo systemctl restart telemetry-api.service

# View API logs
sudo journalctl -u telemetry-api.service -f

# Check API status
sudo systemctl status telemetry-api.service
```
