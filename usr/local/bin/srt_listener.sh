#!/bin/bash

ffmpeg -hide_banner -loglevel error \
-rtsp_transport tcp \
-i rtsp://127.0.0.1:8554/cam \
-c:v copy \
-f mpegts \
"srt://0.0.0.0:8890?mode=listener&latency=200"