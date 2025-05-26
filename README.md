Usage example:
Listen on ports 80, 81 and forward to 192.68.1.1 and 192.68.1.2
```
 docker run -d --net=host \
   wol-tcp-proxy \
   "192.168.1.1,80,12:23:34:45:56:67" \
   "192.168.1.2,81,12:23:34:45:56:68"
```