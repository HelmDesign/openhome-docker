# OpenHome in Docker with noVNC

Multi-stage Docker setup for running OpenHome (Pokemon save file transfer tool) with web-based GUI access via noVNC.

## Features

- **Multi-stage build**: Reduces final image size by ~1.5GB (builder stage discarded)
- **File access**: Volume mount at `/data` for your Pokemon save files
- **Web GUI**: Access via browser at `http://localhost:6080`
- **VNC support**: Direct VNC connection available at `localhost:5901` if needed
- **Persistent storage**: Save files remain accessible and editable

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Create saves directory
mkdir -p saves

# Copy your Pokemon save files to ./saves/

# Build and run
docker-compose up -d

# Access at http://localhost:6080
```

### Option 2: Docker CLI

```bash
# Build the image
docker build -t openhome-novnc .

# Run the container with your save files
docker run -d \
  --name openhome \
  -p 6080:6080 \
  -p 5901:5901 \
  -v /path/to/your/saves:/data \
  openhome-novnc
```

## File Access

Your Pokemon save files are mounted at `/data` inside the container:

```
Your Computer          Container
./saves/      ------>  /data/
  └─ save.sav         └─ save.sav
```

### Adding Save Files

1. **Before running**: Copy files to `./saves/` directory
2. **After running**: Use the noVNC GUI file manager to transfer files

### Accessing Files from Host

Files in `./saves/` are immediately accessible and persist after container stops.

## Usage

1. **Open browser**: Go to `http://localhost:6080`
2. **noVNC interface**: Click "Connect" (no password set by default)
3. **Launch OpenHome**: Use the terminal or application launcher in XFCE
4. **Transfer Pokemon**: Use OpenHome's GUI to manage your save files
5. **Files saved**: Changes are automatically saved to `/data/` → `./saves/`

## VNC Password

To set a VNC password, modify the Dockerfile:

```dockerfile
RUN echo "your-password" | vncpasswd -f > /home/user/.vnc/passwd
```

Or set it after first launch by accessing the container:

```bash
docker exec -it openhome vncpasswd
```

## Container Details

### Image Layers (Multi-stage)

**Stage 1 (Builder)**: 
- Rust toolchain (~1.5GB)
- OpenHome source
- Compiled binary (~50MB)
- **Discarded after build**

**Stage 2 (Runtime)**:
- Ubuntu 22.04 base
- VNC, noVNC, XFCE4
- OpenHome binary
- **Final size: ~800MB**

### Resource Usage

- **CPU**: Minimal (uses only during build)
- **Memory**: ~500MB at runtime
- **Disk**: ~800MB image + save file size

## Troubleshooting

### noVNC won't connect
```bash
# Check logs
docker logs openhome-novnc

# Verify VNC is running
docker exec openhome-novnc ps aux | grep vnc
```

### Can't find save files
```bash
# Verify volume mount
docker inspect openhome-novnc | grep -A 5 Mounts

# Check permissions
ls -la ./saves/
```

### OpenHome won't launch
```bash
# SSH into container
docker exec -it openhome-novnc bash

# Try running manually
cd /data
openhome
```

## Configuration

### Change Resolution
Edit Dockerfile or docker-compose:
```dockerfile
vncserver :1 -geometry 2560x1440 -depth 24 -localhost no
```

### Change Web Port
```yaml
ports:
  - "8080:6080"  # Access at http://localhost:8080
```

### Persistent VNC Settings
Create `.vnc/config` inside container to save preferences.

## Performance Tips

- **Larger saves**: Increase memory allocation if needed
- **Slow I/O**: Ensure Docker has sufficient disk bandwidth
- **Network lag**: Run on same machine or low-latency network

## Docker Compose Commands

```bash
# Build and start
docker-compose up -d

# View logs
docker-compose logs -f openhome-novnc

# Stop container
docker-compose down

# Remove image and volumes
docker-compose down -v
```

## Security Note

- Default setup has no VNC password
- Not recommended for public-facing deployments
- Use VPN or firewall to restrict access
- Change default password in Dockerfile before building

## License

OpenHome by andrewbenington - follows original project license