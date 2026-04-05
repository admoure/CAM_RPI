# 📡 Raspberry Pi Camera Publisher

Sistema de captura y publicación de vídeo en tiempo real basado en Raspberry Pi.

Este nodo está diseñado para entornos de campo y se encarga exclusivamente de:
- Capturar vídeo desde una cámara local (Raspberry Pi Camera)
- Publicar el stream mediante MediaMTX (RTSP / SRT)
- Generar snapshots periódicos
- Exponer una API simple de estado
- Almacenar imágenes como backup en almacenamiento externo

---

## 🧱 Arquitectura

Cámara → Raspberry Pi  
    ├── rpicam-vid  
    ├── ffmpeg  
    ├── MediaMTX  
    ├── Snapshot service  
    ├── Backup a USB (buffer circular)  
    └── API (cam_server.py)  

---

## 📂 Contenido del repositorio

### ⚙️ Configuración
- mediamtx.yml → Configuración del servidor MediaMTX  

### 🔧 Servicios systemd (/etc/systemd/system/)
- mediamtx.service  
- cam-publish.service  
- snapshot.service  
- snapshot.timer  
- cam_server.service  

### 🧠 Scripts
- cam_publish.sh  
- srt_listener.sh  
- snapshot.sh  
- cam_server.py  

---

## 📦 Dependencias externas

Este repositorio NO incluye binarios.

### MediaMTX

Debe instalarse manualmente en:
/usr/local/bin/mediamtx

Ejemplo:

wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_armv7.tar.gz  
tar -xzf mediamtx_*.tar.gz  
sudo mv mediamtx /usr/local/bin/

---

## 📸 Snapshots

- Guardados en RAM: /dev/shm/actual.jpg  
- Generados periódicamente con snapshot.timer  

---

## 💾 Backup en USB

- Copia desde RAM a USB  
- Buffer circular (sobrescribe imágenes antiguas)  

### Tolerancia a fallos
El sistema no depende del USB → el vídeo sigue funcionando aunque falle  

### Formato del USB

sudo mkfs.ext4 -L IMAGENES /dev/sdX

### fstab

LABEL=IMAGENES  /mnt/imagenes  ext4  defaults,nofail,noatime  0  2

---

## 🔒 Sistema en modo solo lectura

proc            /proc           proc    defaults          0  0
/dev/mmcblk0p1  /boot           vfat    ro                0  2
/dev/mmcblk0p2  /               ext4    ro                0  1

tmpfs           /tmp            tmpfs   defaults,noatime,nosuid,size=100m  0  0
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /var/tmp        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /run            tmpfs   defaults,noatime,nosuid,size=50m   0  0

---

## 📝 Logs en RAM

/etc/systemd/journald.conf

Storage=volatile  
RuntimeMaxUse=50M  

sudo systemctl restart systemd-journald

---

## 🕒 NTP (VPN)

/etc/systemd/timesyncd.conf

[Time]  
NTP=10.13.83.136  

sudo systemctl restart systemd-timesyncd

---

## 🔧 Instalación

1. Instalar mediamtx en /usr/local/bin/
2. Copiar repo/etc/mediamtx/mediamtx.yml a /etc/mediamtx/
3. Copiar scripts de repo/usr/local/bin a /usr/local/bin/  
4. Copiar servicios de repo/etc/systemd/system/ a /etc/systemd/system/  

sudo systemctl daemon-reexec  
sudo systemctl daemon-reload  

sudo systemctl enable mediamtx  
sudo systemctl enable cam-publish  
sudo systemctl enable snapshot.timer  
sudo systemctl enable cam_server  

sudo systemctl start mediamtx  
sudo systemctl start cam-publish  
sudo systemctl start snapshot.timer  
sudo systemctl start cam_server  

---

## 🧪 Debug

journalctl -u cam-publish -f  
journalctl -u mediamtx -f  
journalctl -u snapshot -f  

---

## 📌 Notas

- Diseñado para campo  
- No depende del USB  
- Minimiza escrituras en SD  

---

## 📜 Licencia

Uso interno / investigación
