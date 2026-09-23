# Stage 1: Builder
FROM rust:latest as builder

WORKDIR /build
RUN git clone https://github.com/andrewbenington/OpenHome.git .
RUN cargo build --release

# Stage 2: Runtime
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    tigervnc-server \
    novnc \
    websockify \
    xfce4 \
    xfce4-terminal \
    xfce4-panel \
    xfce4-session \
    dbus-x11 \
    x11-utils \
    && rm -rf /var/lib/apt/lists/*

# Copy built binary from builder
COPY --from=builder /build/target/release/openhome /usr/local/bin/openhome

# Create directories
RUN mkdir -p /home/user/.vnc /data && chmod 755 /data

# Create VNC password
RUN echo "password" | vncpasswd -f > /home/user/.vnc/passwd && chmod 600 /home/user/.vnc/passwd

# Create VNC startup script
RUN cat > /home/user/.vnc/xstartup << 'XSTARTUP'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4 &
XSTARTUP
chmod +x /home/user/.vnc/xstartup

# Create startup script
RUN cat > /start.sh << 'STARTSCRIPT'
#!/bin/bash
set -e

# Start D-Bus daemon
dbus-daemon --system --print-address

# Start VNC server
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# Start noVNC websocket proxy in background
websockify -D --web=/usr/share/novnc 6080 localhost:5901

# Start OpenHome in the background and launch it with a terminal window
cd /data
xterm -e "openhome" &

# Keep container running
tail -f /dev/null
STARTSCRIPT
chmod +x /start.sh

# Expose ports
EXPOSE 5901 6080

# Set environment
ENV DISPLAY=:1
ENV HOME=/home/user

# Mount point for save files
VOLUME ["/data"]

# Run startup script
CMD ["/start.sh"]