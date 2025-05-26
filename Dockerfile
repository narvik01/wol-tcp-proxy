FROM alpine/socat

# Create and set working directory
WORKDIR /app

# Copy application files
COPY app/* /app/

# Set the entrypoint to our script
ENTRYPOINT ["/app/start-listeners.sh"]

# Usage example:
# docker run -d --net=host \
#   wol-tcp-proxy \
#   "192.168.1.1,80,12:23:34:45:56:67" \
#   "192.168.1.2,81,12:23:34:45:56:68" \

