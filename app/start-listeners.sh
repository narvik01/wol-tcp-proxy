#!/bin/ash

# Check if any parameters were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 IP,PORT,MAC [IP2,PORT2,MAC2 ...]"
    echo "Example: $0 192.168.1.100,8080,00:11:22:33:44:55 192.168.1.101,8443,AA:BB:CC:DD:EE:FF"
    exit 1
fi

echo "Starting WOL TCP Proxy listeners..."

# Create a temporary file to store PIDs
PID_FILE="/tmp/wol_listener_pids.$$"
LOGFILE="/tmp/wol-proxy.log"

# Create or clear the PID file and log file
: > "$PID_FILE"
: > "$LOGFILE"

# Start log file monitor in background to show debug messages in docker logs
tail -f "$LOGFILE" 2>/dev/null &
LOG_TAIL_PID=$!
echo $LOG_TAIL_PID >> "$PID_FILE"

# Function to handle cleanup
cleanup() {
    echo "Shutting down listeners..."
    # Kill all background processes
    xargs -r kill < "$PID_FILE" 2>/dev/null
    rm -f "$PID_FILE"
    exit 0
}

# Set up trap to catch termination signals
trap cleanup TERM INT

# Start each listener in the background
for param in "$@"; do
    # Split the parameter into IP, PORT, and MAC
    IFS=','
    set -- $param
    IP="$1"
    PORT="$2"
    MAC="$3"
    
    if [ -z "$IP" ] || [ -z "$PORT" ] || [ -z "$MAC" ]; then
        echo "Error: Invalid parameter format: $param. Expected IP,PORT,MAC"
        continue
    fi
    
    echo "Starting listener for $IP:$PORT (MAC: $MAC)"
    
    # Start the listener in the background
    /app/socat-wol-listener.sh "$IP" "$PORT" "$MAC" &
    
    # Store the PID
    echo $! >> "$PID_FILE"
done

# Wait for all background processes
# This will keep the container running until it's terminated
while true; do
    sleep 3600 &
    wait $!
done

# This line should never be reached due to the infinite loop in the listeners
echo "All listeners have stopped unexpectedly"
exit 1
