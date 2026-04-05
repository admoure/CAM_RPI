📡 Raspberry Pi Camera Publisher

Sistema de captura y publicación de vídeo en tiempo real basado en Raspberry Pi.

Este nodo está diseñado para entornos de campo y se encarga exclusivamente de:

Capturar vídeo desde una cámara local (Raspberry Pi Camera)
Publicar el stream mediante MediaMTX (RTSP / SRT)
Generar snapshots periódicos
Exponer una API simple de estado
Almacenar imágenes como backup en almacenamiento externo
🧱 Arquitectura

Cámara → Raspberry Pi
  ├── rpicam-vid
  ├── ffmpeg
  ├── MediaMTX
  ├── Snapshot service
  ├── Backup a USB (buffer circular)
  └── API (cam_server.py)

📂 Contenido del repositorio
⚙️ Configuración
mediamtx.yml → Configuración del servidor MediaMTX
🔧 Servicios systemd (en /etc/systemd/system/)
mediamtx.service
cam-publish.service
snapshot.service
snapshot.timer
cam_server.service
🧠 Scripts
cam_publish.sh
srt_listener.sh
snapshot.sh
cam_server.py
📦 Dependencias externas

Este repositorio NO incluye binarios.

MediaMTX

Debe instalarse manualmente en /usr/local/bin/mediamtx.

Ejemplo:

wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_armv7.tar.gz
tar -xzf mediamtx_*.tar.gz
sudo mv mediamtx /usr/local/bin/
🎥 Captura de vídeo

La captura se realiza con rpicam-vid y se publica mediante ffmpeg hacia MediaMTX.

📡 Streaming

MediaMTX:

RTSP local
SRT hacia servidor remoto

Este nodo no gestiona clientes finales, solo publica el stream.

📸 Snapshots
Capturados desde RTSP local
Guardados en RAM: /dev/shm/actual.jpg
Generados periódicamente mediante snapshot.timer
💾 Backup en USB

Las imágenes se generan en RAM y posteriormente se copian a un pendrive.

Funcionamiento
Escritura principal en RAM (/dev/shm)
Copia a USB como backup
Uso de buffer circular:
Sobrescribe las imágenes más antiguas cuando se llena
Evita quedarse sin espacio
Tolerancia a fallos

El sistema NO depende del pendrive:

Si el USB falla o se desconecta → el sistema sigue funcionando
No se interrumpe la transmisión de vídeo
Sustitución del pendrive

El nuevo pendrive debe estar en ext4 con label IMAGENES:

sudo mkfs.ext4 -L IMAGENES /dev/sdX
Montaje automático

Añadir en /etc/fstab:

LABEL=IMAGENES  /mnt/imagenes  ext4  defaults,nofail,noatime  0  2
🔒 Sistema en modo solo lectura

Para aumentar la robustez en campo.

fstab
proc            /proc           proc    defaults          0  0
/dev/mmcblk0p1  /boot           vfat    ro                0  2
/dev/mmcblk0p2  /               ext4    ro                0  1

tmpfs           /tmp            tmpfs   defaults,noatime,nosuid,size=100m  0  0
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /var/tmp        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /run            tmpfs   defaults,noatime,nosuid,size=50m   0  0

LABEL=IMAGENES  /mnt/imagenes   ext4    defaults,nofail,noatime  0  2
📝 Logs en RAM

Editar /etc/systemd/journald.conf:

Storage=volatile
RuntimeMaxUse=50M

Aplicar:

sudo systemctl restart systemd-journald
🕒 Configuración NTP (VPN)

Editar /etc/systemd/timesyncd.conf:

[Time]
NTP=192.168.1.1
FallbackNTP=

Reiniciar:

sudo systemctl restart systemd-timesyncd
🌐 API
/snapshot → Imagen actual
/status → Estado del sistema
🧯 Robustez
systemd con reinicio automático
filesystem en solo lectura
logs en RAM
tolerante a fallo de USB
minimiza escrituras en SD
🔧 Instalación
Copiar scripts a /usr/local/bin/
Copiar servicios a /etc/systemd/system/
Recargar systemd:
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
Activar servicios:
sudo systemctl enable mediamtx
sudo systemctl enable cam-publish
sudo systemctl enable snapshot.timer
sudo systemctl enable cam_server
Iniciar:
sudo systemctl start mediamtx
sudo systemctl start cam-publish
sudo systemctl start snapshot.timer
sudo systemctl start cam_server
🧪 Debug
journalctl -u cam-publish -f
journalctl -u mediamtx -f
journalctl -u snapshot -f
📌 Notas
Diseñado para despliegues remotos
Optimizado para redes inestables
No depende de almacenamiento externo
Minimiza escrituras en SD
📜 Licencia

Uso interno / investigación📡 Raspberry Pi Camera Publisher

Sistema de captura y publicación de vídeo en tiempo real basado en Raspberry Pi.

Este nodo está diseñado para entornos de campo y se encarga exclusivamente de:

Capturar vídeo desde una cámara local (Raspberry Pi Camera)
Publicar el stream mediante MediaMTX (RTSP / SRT)
Generar snapshots periódicos
Exponer una API simple de estado
Almacenar imágenes como backup en almacenamiento externo
🧱 Arquitectura

Cámara → Raspberry Pi
  ├── rpicam-vid
  ├── ffmpeg
  ├── MediaMTX
  ├── Snapshot service
  ├── Backup a USB (buffer circular)
  └── API (cam_server.py)

📂 Contenido del repositorio
⚙️ Configuración
mediamtx.yml → Configuración del servidor MediaMTX
🔧 Servicios systemd (en /etc/systemd/system/)
mediamtx.service
cam-publish.service
snapshot.service
snapshot.timer
cam_server.service
🧠 Scripts
cam_publish.sh
srt_listener.sh
snapshot.sh
cam_server.py
📦 Dependencias externas

Este repositorio NO incluye binarios.

MediaMTX

Debe instalarse manualmente en /usr/local/bin/mediamtx.

Ejemplo:

wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_armv7.tar.gz
tar -xzf mediamtx_*.tar.gz
sudo mv mediamtx /usr/local/bin/
🎥 Captura de vídeo

La captura se realiza con rpicam-vid y se publica mediante ffmpeg hacia MediaMTX.

📡 Streaming

MediaMTX:

RTSP local
SRT hacia servidor remoto

Este nodo no gestiona clientes finales, solo publica el stream.

📸 Snapshots
Capturados desde RTSP local
Guardados en RAM: /dev/shm/actual.jpg
Generados periódicamente mediante snapshot.timer
💾 Backup en USB

Las imágenes se generan en RAM y posteriormente se copian a un pendrive.

Funcionamiento
Escritura principal en RAM (/dev/shm)
Copia a USB como backup
Uso de buffer circular:
Sobrescribe las imágenes más antiguas cuando se llena
Evita quedarse sin espacio
Tolerancia a fallos

El sistema NO depende del pendrive:

Si el USB falla o se desconecta → el sistema sigue funcionando
No se interrumpe la transmisión de vídeo
Sustitución del pendrive

El nuevo pendrive debe estar en ext4 con label IMAGENES:

sudo mkfs.ext4 -L IMAGENES /dev/sdX
Montaje automático

Añadir en /etc/fstab:

LABEL=IMAGENES  /mnt/imagenes  ext4  defaults,nofail,noatime  0  2
🔒 Sistema en modo solo lectura

Para aumentar la robustez en campo.

fstab
proc            /proc           proc    defaults          0  0
/dev/mmcblk0p1  /boot           vfat    ro                0  2
/dev/mmcblk0p2  /               ext4    ro                0  1

tmpfs           /tmp            tmpfs   defaults,noatime,nosuid,size=100m  0  0
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /var/tmp        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /run            tmpfs   defaults,noatime,nosuid,size=50m   0  0

LABEL=IMAGENES  /mnt/imagenes   ext4    defaults,nofail,noatime  0  2
📝 Logs en RAM

Editar /etc/systemd/journald.conf:

Storage=volatile
RuntimeMaxUse=50M

Aplicar:

sudo systemctl restart systemd-journald
🕒 Configuración NTP (VPN)

Editar /etc/systemd/timesyncd.conf:

[Time]
NTP=192.168.1.1
FallbackNTP=

Reiniciar:

sudo systemctl restart systemd-timesyncd
🌐 API
/snapshot → Imagen actual
/status → Estado del sistema
🧯 Robustez
systemd con reinicio automático
filesystem en solo lectura
logs en RAM
tolerante a fallo de USB
minimiza escrituras en SD
🔧 Instalación
Copiar scripts a /usr/local/bin/
Copiar servicios a /etc/systemd/system/
Recargar systemd:
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
Activar servicios:
sudo systemctl enable mediamtx
sudo systemctl enable cam-publish
sudo systemctl enable snapshot.timer
sudo systemctl enable cam_server
Iniciar:
sudo systemctl start mediamtx
sudo systemctl start cam-publish
sudo systemctl start snapshot.timer
sudo systemctl start cam_server
🧪 Debug
journalctl -u cam-publish -f
journalctl -u mediamtx -f
journalctl -u snapshot -f
📌 Notas
Diseñado para despliegues remotos
Optimizado para redes inestables
No depende de almacenamiento externo
Minimiza escrituras en SD
📜 Licencia

Uso interno / investigación📡 Raspberry Pi Camera Publisher

Sistema de captura y publicación de vídeo en tiempo real basado en Raspberry Pi.

Este nodo está diseñado para entornos de campo y se encarga exclusivamente de:

Capturar vídeo desde una cámara local (Raspberry Pi Camera)
Publicar el stream mediante MediaMTX (RTSP / SRT)
Generar snapshots periódicos
Exponer una API simple de estado
Almacenar imágenes como backup en almacenamiento externo
🧱 Arquitectura

Cámara → Raspberry Pi
  ├── rpicam-vid
  ├── ffmpeg
  ├── MediaMTX
  ├── Snapshot service
  ├── Backup a USB (buffer circular)
  └── API (cam_server.py)

📂 Contenido del repositorio
⚙️ Configuración
mediamtx.yml → Configuración del servidor MediaMTX
🔧 Servicios systemd (en /etc/systemd/system/)
mediamtx.service
cam-publish.service
snapshot.service
snapshot.timer
cam_server.service
🧠 Scripts
cam_publish.sh
srt_listener.sh
snapshot.sh
cam_server.py
📦 Dependencias externas

Este repositorio NO incluye binarios.

MediaMTX

Debe instalarse manualmente en /usr/local/bin/mediamtx.

Ejemplo:

wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_armv7.tar.gz
tar -xzf mediamtx_*.tar.gz
sudo mv mediamtx /usr/local/bin/
🎥 Captura de vídeo

La captura se realiza con rpicam-vid y se publica mediante ffmpeg hacia MediaMTX.

📡 Streaming

MediaMTX:

RTSP local
SRT hacia servidor remoto

Este nodo no gestiona clientes finales, solo publica el stream.

📸 Snapshots
Capturados desde RTSP local
Guardados en RAM: /dev/shm/actual.jpg
Generados periódicamente mediante snapshot.timer
💾 Backup en USB

Las imágenes se generan en RAM y posteriormente se copian a un pendrive.

Funcionamiento
Escritura principal en RAM (/dev/shm)
Copia a USB como backup
Uso de buffer circular:
Sobrescribe las imágenes más antiguas cuando se llena
Evita quedarse sin espacio
Tolerancia a fallos

El sistema NO depende del pendrive:

Si el USB falla o se desconecta → el sistema sigue funcionando
No se interrumpe la transmisión de vídeo
Sustitución del pendrive

El nuevo pendrive debe estar en ext4 con label IMAGENES:

sudo mkfs.ext4 -L IMAGENES /dev/sdX
Montaje automático

Añadir en /etc/fstab:

LABEL=IMAGENES  /mnt/imagenes  ext4  defaults,nofail,noatime  0  2
🔒 Sistema en modo solo lectura

Para aumentar la robustez en campo.

fstab
proc            /proc           proc    defaults          0  0
/dev/mmcblk0p1  /boot           vfat    ro                0  2
/dev/mmcblk0p2  /               ext4    ro                0  1

tmpfs           /tmp            tmpfs   defaults,noatime,nosuid,size=100m  0  0
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /var/tmp        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /run            tmpfs   defaults,noatime,nosuid,size=50m   0  0

LABEL=IMAGENES  /mnt/imagenes   ext4    defaults,nofail,noatime  0  2
📝 Logs en RAM

Editar /etc/systemd/journald.conf:

Storage=volatile
RuntimeMaxUse=50M

Aplicar:

sudo systemctl restart systemd-journald
🕒 Configuración NTP (VPN)

Editar /etc/systemd/timesyncd.conf:

[Time]
NTP=192.168.1.1
FallbackNTP=

Reiniciar:

sudo systemctl restart systemd-timesyncd
🌐 API
/snapshot → Imagen actual
/status → Estado del sistema
🧯 Robustez
systemd con reinicio automático
filesystem en solo lectura
logs en RAM
tolerante a fallo de USB
minimiza escrituras en SD
🔧 Instalación
Copiar scripts a /usr/local/bin/
Copiar servicios a /etc/systemd/system/
Recargar systemd:
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
Activar servicios:
sudo systemctl enable mediamtx
sudo systemctl enable cam-publish
sudo systemctl enable snapshot.timer
sudo systemctl enable cam_server
Iniciar:
sudo systemctl start mediamtx
sudo systemctl start cam-publish
sudo systemctl start snapshot.timer
sudo systemctl start cam_server
🧪 Debug
journalctl -u cam-publish -f
journalctl -u mediamtx -f
journalctl -u snapshot -f
📌 Notas
Diseñado para despliegues remotos
Optimizado para redes inestables
No depende de almacenamiento externo
Minimiza escrituras en SD
📜 Licencia

Uso interno / investigación📡 Raspberry Pi Camera Publisher

Sistema de captura y publicación de vídeo en tiempo real basado en Raspberry Pi.

Este nodo está diseñado para entornos de campo y se encarga exclusivamente de:

Capturar vídeo desde una cámara local (Raspberry Pi Camera)
Publicar el stream mediante MediaMTX (RTSP / SRT)
Generar snapshots periódicos
Exponer una API simple de estado
Almacenar imágenes como backup en almacenamiento externo
🧱 Arquitectura

Cámara → Raspberry Pi
  ├── rpicam-vid
  ├── ffmpeg
  ├── MediaMTX
  ├── Snapshot service
  ├── Backup a USB (buffer circular)
  └── API (cam_server.py)

📂 Contenido del repositorio
⚙️ Configuración
mediamtx.yml → Configuración del servidor MediaMTX
🔧 Servicios systemd (en /etc/systemd/system/)
mediamtx.service
cam-publish.service
snapshot.service
snapshot.timer
cam_server.service
🧠 Scripts
cam_publish.sh
srt_listener.sh
snapshot.sh
cam_server.py
📦 Dependencias externas

Este repositorio NO incluye binarios.

MediaMTX

Debe instalarse manualmente en /usr/local/bin/mediamtx.

Ejemplo:

wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_armv7.tar.gz
tar -xzf mediamtx_*.tar.gz
sudo mv mediamtx /usr/local/bin/
🎥 Captura de vídeo

La captura se realiza con rpicam-vid y se publica mediante ffmpeg hacia MediaMTX.

📡 Streaming

MediaMTX:

RTSP local
SRT hacia servidor remoto

Este nodo no gestiona clientes finales, solo publica el stream.

📸 Snapshots
Capturados desde RTSP local
Guardados en RAM: /dev/shm/actual.jpg
Generados periódicamente mediante snapshot.timer
💾 Backup en USB

Las imágenes se generan en RAM y posteriormente se copian a un pendrive.

Funcionamiento
Escritura principal en RAM (/dev/shm)
Copia a USB como backup
Uso de buffer circular:
Sobrescribe las imágenes más antiguas cuando se llena
Evita quedarse sin espacio
Tolerancia a fallos

El sistema NO depende del pendrive:

Si el USB falla o se desconecta → el sistema sigue funcionando
No se interrumpe la transmisión de vídeo
Sustitución del pendrive

El nuevo pendrive debe estar en ext4 con label IMAGENES:

sudo mkfs.ext4 -L IMAGENES /dev/sdX
Montaje automático

Añadir en /etc/fstab:

LABEL=IMAGENES  /mnt/imagenes  ext4  defaults,nofail,noatime  0  2
🔒 Sistema en modo solo lectura

Para aumentar la robustez en campo.

fstab
proc            /proc           proc    defaults          0  0
/dev/mmcblk0p1  /boot           vfat    ro                0  2
/dev/mmcblk0p2  /               ext4    ro                0  1

tmpfs           /tmp            tmpfs   defaults,noatime,nosuid,size=100m  0  0
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /var/tmp        tmpfs   defaults,noatime,nosuid,size=50m   0  0
tmpfs           /run            tmpfs   defaults,noatime,nosuid,size=50m   0  0

LABEL=IMAGENES  /mnt/imagenes   ext4    defaults,nofail,noatime  0  2
📝 Logs en RAM

Editar /etc/systemd/journald.conf:

Storage=volatile
RuntimeMaxUse=50M

Aplicar:

sudo systemctl restart systemd-journald
🕒 Configuración NTP (VPN)

Editar /etc/systemd/timesyncd.conf:

[Time]
NTP=192.168.1.1
FallbackNTP=

Reiniciar:

sudo systemctl restart systemd-timesyncd
🌐 API
/snapshot → Imagen actual
/status → Estado del sistema
🧯 Robustez
systemd con reinicio automático
filesystem en solo lectura
logs en RAM
tolerante a fallo de USB
minimiza escrituras en SD
🔧 Instalación
Copiar scripts a /usr/local/bin/
Copiar servicios a /etc/systemd/system/
Recargar systemd:
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
Activar servicios:
sudo systemctl enable mediamtx
sudo systemctl enable cam-publish
sudo systemctl enable snapshot.timer
sudo systemctl enable cam_server
Iniciar:
sudo systemctl start mediamtx
sudo systemctl start cam-publish
sudo systemctl start snapshot.timer
sudo systemctl start cam_server
🧪 Debug
journalctl -u cam-publish -f
journalctl -u mediamtx -f
journalctl -u snapshot -f
📌 Notas
Diseñado para despliegues remotos
Optimizado para redes inestables
No depende de almacenamiento externo
Minimiza escrituras en SD
📜 Licencia

Uso interno / investigación# 📡 Raspberry Pi Camera Publisher

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

proc	/proc	proc	defaults	0	0  
PARTUUID=c77adlc0-01	/boot/firmware	vfat	defaults	0	2  
PARTUUID=c77ad1c0-02	/		ext4	defaults,noatime,ro	0	1  

tmpfs	/tmp	tmpfs	defaults,noatime,nosuid,size=100m	0	0  
tmpfs	/var/log	tmpfs	defaults,noatime,nosuid,size=50m	0	0  
tmpfs	/var/tmp	tmpfs	defaults,noatime,nosuid,size=100m	0	0  



tmpfs 	/var/run 	tmpfs 	defaults,noatime,nosuid,size=20m 	0 	0  

LABEL=IMAGENES 	/mnt/imagenes 	ext4 	defaults,nofail,noatime 	0 	2  

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
NTP=192.168.1.1  
FallbackNTP=  

sudo systemctl restart systemd-timesyncd

---

## 🔧 Instalación

1. Instalar mediamtx en /usr/local/bin
2. Copiar mediamtx.yml (NO el que viene con mediamtx) a /etc/mediamtx/
4. Copiar scripts a /usr/local/bin/  
5. Copiar servicios a /etc/systemd/system/  

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
