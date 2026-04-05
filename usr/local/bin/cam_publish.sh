#!/bin/bash
#-e sale si un comando falla
#-u error si variable no definida
# pipefail sale si cualquier comando del pipe falla
# Sale al primero error, no permite variables no definidas, detecta fallos en pipes

set -euo pipefail

rpicam-vid -n -t 0 --vflip --hflip \
  --autofocus-mode manual --lens-position 0 \
  --width 1920 --height 1080 \
  --framerate 25 \
  --bitrate 3000000 \
  --intra 25 \
  --inline \
  -o - \
| ffmpeg -hide_banner -loglevel error \
  -f h264 -i - \
  -c:v copy \
  -f rtsp -rtsp_transport tcp \
  rtsp://127.0.0.1:8554/cam
