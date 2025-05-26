#!/bin/ash

IP=$1
PORT=$2
MAC=$3
HANDLER_SCRIPT="/app/wol-handler.sh"

while true; do
  socat -d -d TCP4-LISTEN:$PORT,reuseaddr,fork EXEC:\""$HANDLER_SCRIPT $IP $PORT $MAC"\"
done
