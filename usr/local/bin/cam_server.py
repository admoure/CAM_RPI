#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import json
import time
import datetime
from datetime import datetime, UTC
import shutil

# ==========================
# CONFIGURACIÓN
# ==========================

CAM_NAME = "LNOR"                     # Cambia en cada Raspberry
SNAPSHOT_PATH = "/dev/shm/actual.jpg"
USB_MOUNT = "/mnt/imagenes"           # Punto de montaje del pendrive
PORT = 8080

# ==========================
# FUNCIONES AUXILIARES
# ==========================

def iso_utc(ts):
    return datetime.fromtimestamp(ts,UTC).replace(microsecond=0).isoformat()

def get_usb_status(path):
    info = {
        "present": os.path.exists(path),
        "mounted": os.path.ismount(path),
        "path": path
    }

    if info["mounted"]:
        total, used, free = shutil.disk_usage(path)
        info.update({
            "total_gb": round(total / (1024**3), 2),
            "used_gb": round(used / (1024**3), 2),
            "free_gb": round(free / (1024**3), 2),
            "used_pct": round((used / total) * 100, 1) if total else None
        })

    return info

# ==========================
# SERVIDOR HTTP
# ==========================

class CamHandler(BaseHTTPRequestHandler):

    def do_GET(self):

        if self.path == "/snapshot":
            self.handle_snapshot()

        elif self.path == "/status":
            self.handle_status()

        else:
            self.send_response(404)
            self.end_headers()

    def handle_snapshot(self):

        if os.path.exists(SNAPSHOT_PATH):
            try:
                self.send_response(200)
                self.send_header("Content-Type", "image/jpeg")
                self.end_headers()

                with open(SNAPSHOT_PATH, "rb") as f:
                    self.wfile.write(f.read())

            except Exception:
                self.send_response(500)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def handle_status(self):

        now = time.time()

        snapshot_info = {
            "exists": os.path.exists(SNAPSHOT_PATH),
            "path": SNAPSHOT_PATH
        }

        if snapshot_info["exists"]:
            st = os.stat(SNAPSHOT_PATH)
            snapshot_info.update({
                "mtime_utc": iso_utc(st.st_mtime),
                "age_s": int(now - st.st_mtime),
                "size_bytes": st.st_size
            })

        payload = {
            "name": CAM_NAME,
            "ok": snapshot_info["exists"],
            "snapshot": snapshot_info,
            "usb": get_usb_status(USB_MOUNT),
            "server_time_utc": iso_utc(now)
        }

        body = json.dumps(payload).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        # Desactivar logs en consola
        return


# ==========================
# MAIN
# ==========================

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), CamHandler)
    server.serve_forever()
