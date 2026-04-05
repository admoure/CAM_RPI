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
  * No se usa, solo para pruebas de protocolo SRT directo
- snapshot.sh  
  * Editar y cambiar el nombre de la estación ```bash STATION="  "```
- cam_server.py
  * Editar y cambiar el nombre de la estación ```bash CAM_NAME="  "```  

---

## 📦 Dependencias externas

Este repositorio NO incluye binarios.

### MediaMTX

Debe instalarse manualmente en:
/usr/local/bin/mediamtx

Ejemplo:
```bash
wget https://github.com/bluenviron/mediamtx/releases/download/v1.17.1/mediamtx_v1.17.1_linux_arm64.tar.gz
tar -xzf mediamtx_v1.17.1_linux_arm64.tar.gz  
sudo mv mediamtx /usr/local/bin/
```
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
```bash
sudo mkfs.ext4 -L IMAGENES /dev/sdX
```
### fstab

LABEL=IMAGENES  /mnt/imagenes  ext4  defaults,nofail,noatime  0  2

---

## 🔒 Sistema en modo solo lectura

```bash
proc            /proc           proc    defaults          0  0
PARTUUID=c77ad1c0-01    /boot/firmware    vfat  defaults    0   2
PARTUUID=c77ad1c0-02    /                 ext4  defaults,noatime,ro     0  1

tmpfs           /tmp            tmpfs   defaults,noatime,nosuid,size=100m  0  0
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,size=100m  0  0
tmpfs           /var/tmp        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /var/run        tmpfs   defaults,noatime,nosuid,size=50m   0  0

LABEL=IMAGENES  /mtn/imagenes   ext4    defaults,noatime,nosuid,nofail     0  2
```

### 📝 Logs en RAM
```bash
nano /etc/systemd/journald.conf
```
Storage=volatile  
RuntimeMaxUse=50M  
```bash
sudo systemctl restart systemd-journald
``` 

### 🕒 NTP (VPN)
```bash
nano /etc/systemd/timesyncd.conf
```
[Time]  
NTP=10.13.83.136  
```bash
sudo systemctl restart systemd-timesyncd
```
---

## 🔧 Instalación

Instalar mediamtx en /usr/local/bin/
```bash
git clone <repo>
cd <repo>

sudo cp etc/mediamtx/mediamtx.yml /etc/mediamtx/
sudo cp usr/local/bin/. /usr/local/bin/  
sudo cp etc/systemd/system/. /etc/systemd/system/  

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
```
---

## 🧪 Logs
```bash
journalctl -u cam-publish -f  
journalctl -u mediamtx -f  
journalctl -u snapshot -f  
```
---

## 📌 Notas

- Diseñado para campo  
- No depende del USB  
- Minimiza escrituras en SD  

### Puertos expuestos (abrir en el router)

- RTSP 8554
- SRT 8890
- HTTP 8080
- SSH 22

---

## 👤 Autor

IGN / Canarias
