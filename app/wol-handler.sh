#!/bin/ash

BACKEND_IP=$1
BACKEND_PORT=$2
BACKEND_MAC=$3
TIMEOUT=60
CONNECTION_TIMEOUT=5
LOCKFILE="/tmp/wol_wakeup_${BACKEND_IP}.lock"
LOCK_TIMEOUT=120  # seconds to suppress repeat WoL
LOGFILE="/tmp/wol-proxy.log"

now=$(date +%s)

echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Checking if backend already up at $BACKEND_IP:$BACKEND_PORT" >> "$LOGFILE"
if nc -v -w $CONNECTION_TIMEOUT -z "$BACKEND_IP" "$BACKEND_PORT"; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Backend already up at $BACKEND_IP:$BACKEND_PORT" >> "$LOGFILE"
  exec socat -d -d STDIO TCP4:"$BACKEND_IP":"$BACKEND_PORT"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Check lockfile age" >> "$LOGFILE"
if [ -f "$LOCKFILE" ]; then
  last_trigger=$(stat -c %Y "$LOCKFILE")
  if [ $((now - last_trigger)) -lt "$LOCK_TIMEOUT" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Backend is waking, waiting... (lockfile exists)" >> "$LOGFILE"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Stale lockfile, re-sending WoL to $BACKEND_MAC" >> "$LOGFILE"
    touch "$LOCKFILE"
    ether-wake "$BACKEND_MAC"
  fi
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Sending WoL to $BACKEND_MAC" >> "$LOGFILE"
  touch "$LOCKFILE"
  ether-wake "$BACKEND_MAC"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Waiting for backend to respond" >> "$LOGFILE"
i=0
while [ "$i" -lt "$TIMEOUT" ]; do
  if nc -v -w $CONNECTION_TIMEOUT -z "$BACKEND_IP" "$BACKEND_PORT"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Successfully connected to $BACKEND_IP:$BACKEND_PORT" >> "$LOGFILE"
    break
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Sleep ($i) waiting for $BACKEND_IP:$BACKEND_PORT" >> "$LOGFILE"
    sleep 1
    i=$((i + 1))
  fi
done

# Forward the connection
exec socat -d -d STDIO TCP4:"$BACKEND_IP":"$BACKEND_PORT"
