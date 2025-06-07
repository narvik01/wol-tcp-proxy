# WOL TCP Proxy

A Docker container that acts as a TCP proxy with Wake-on-LAN (WoL) functionality. It listens for TCP connections on specified ports and automatically wakes up target machines using Wake-on-LAN when needed.

## Features

- **Automatic Wake-on-LAN**: Sends WoL magic packets to wake up target machines when a connection is attempted
- **Connection Forwarding**: Forwards TCP connections to the target machine once it's awake
- **Multiple Listeners**: Supports multiple listener configurations in a single container
- **Connection Caching**: Prevents sending multiple WoL packets in quick succession
- **Configurable Timeouts**: Customizable connection and wake-up timeouts

## Requirements

- Docker
- Host network access (for Wake-on-LAN functionality)
- Target machines must be configured to support Wake-on-LAN

## Installation

Build it yourself:

```bash
git clone https://github.com/yourusername/wol-tcp-proxy.git
cd wol-tcp-proxy
docker build -t narviq/wol-tcp-proxy .
```

## Usage

Run the container with one or more listener configurations:

```bash
docker run -d --net=host \
  narviq/wol-tcp-proxy \
  "TARGET_IP,PORT,MAC_ADDRESS" \
  ["TARGET_IP2,PORT2,MAC_ADDRESS2" ...]
```

### Parameters

Each listener configuration consists of three comma-separated values:

- `TARGET_IP`: The IP address of the target machine
- `PORT`: The TCP port to listen on and forward to
- `MAC_ADDRESS`: The MAC address of the target machine (for Wake-on-LAN)

### Examples

Listen on port 80 and forward to 192.168.1.1 with MAC address 12:23:34:45:56:67:

```bash
docker run -d --net=host \
  narviq/wol-tcp-proxy \
  "192.168.1.1,80,12:23:34:45:56:67"
```

Listen on multiple ports and forward to different machines:

```bash
docker run -d --net=host \
  narviq/wol-tcp-proxy \
  "192.168.1.1,80,12:23:34:45:56:67" \
  "192.168.1.2,81,12:23:34:45:56:68" \
  "192.168.1.3,8080,12:23:34:45:56:69"
```

## How It Works

1. The container listens for TCP connections on the specified ports
2. When a connection is received, it checks if the target machine is already up
3. If the target is up, it immediately forwards the connection
4. If the target is down, it sends a Wake-on-LAN packet to the specified MAC address
5. It then waits for the target machine to wake up (with a configurable timeout)
6. Once the target is up, it forwards the connection

## Configuration

The following variables can be set to customize the behavior:

- `TIMEOUT`: Maximum time to wait for the target machine to wake up (default: 60 seconds)
- `CONNECTION_TIMEOUT`: Timeout for connection attempts (default: 5 seconds)
- `LOCK_TIMEOUT`: Time to suppress repeat WoL packets (default: 120 seconds)


## Troubleshooting

- Ensure the target machines are properly configured for Wake-on-LAN
- Check that the MAC addresses are correctly specified
- Verify that the container has network access to send WoL packets (requires host network mode)
- Check the container logs for debugging information:
  ```bash
  docker logs <container_id>
  ```
