#!/bin/bash

set -euo pipefail

OUT_DIR="/dev/shm"    #ESTO ES RAM
TMP="${OUT_DIR}/actual.tmp.jpg"	#DENTRO DE RAM UN TEMPORAL 
OUT="${OUT_DIR}/actual.jpg" #DENTRO DE RAM EL FICHERO DEFINITVO
STATION="LNOR"  #NOMBRE DE LA ESTACION PERO COMO TODO VA A SER RO -> GENERICO
# CAPTURAMOS A RAM, PRIMERO CAPTURA LUEGO RENOMBRA
ffmpeg -hide_banner -loglevel error \
-rtsp_transport tcp -timeout 3000000 \
-i rtsp://127.0.0.1:8554/cam \
-frames:v 1 -q:v 2 \
-vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:\
text='$STATION %{localtime\:%Y-%m-%d %H\\\\\:%M\\\\\:%S}':\
x=20:y=h-60:fontsize=36:fontcolor=white:box=1:boxcolor=black@0.4:boxborderw=10" \
"$TMP"

mv -f "$TMP" "$OUT" #UNA VEZ QUE SE ESCRIBE RENOMBRAMOS

#COPIAMOS AL USB EN CASO DE QUE EXISTA

USB="/mnt/imagenes"
HIGH_WATER=90	#USO DEL 90% DEL USB
LOW_WATER=85	#BORRAMOS HSTA LLEGAR AL 85%

#MIRAMOS SI EXISTE EL USB MIRANDO SI ESTA MONTADO

if mountpoint -q "$USB"; then
	Y="$(date +%Y)"
	M="$(date +%m)"
	D="$(date +%d)"
	T="$(date +%Y%m%d%H%M)"	#FORMATO DEL FICHERO

	DEST_DIR="$USB/$Y/$M/$D"
	mkdir -p "$DEST_DIR" # SI NO EXISTE CREAMOS EL FICHERO

	cp "$OUT" "$DEST_DIR/$T.jpg"  #COPIAMOS EL FICHERO DE RAM AL USB CON LA HORA Y FECHA
	#AHORA BORRAMOS EN CASO DE QUE HAYAMOS LLEGADO A UN MÁXIMO DE CAPACIDAD
	#PERO SOLO BORRAMOS 200 FICHEROS DE GOLPE PORQUE PUEDE TARDAR MUCHO
	#EN LA SIGUIENTE CAPTURA SE BORRARAN OTROS 200 Y ASI
	MAX_DELETES=200
	usage_percent() {
		df -P "$USB" | awk 'NR=2 {gsub("%","",$5); print $5}j'
	}
	#BORRAMOS LAS ANTIGUAS
	if [ "$(usage_percent)" -ge "$HIGH_WATER" ]; then
		deletes=0
		while [ "$(usage_percent)" -gt "$LOW_WATER" ] && [ "$deletes" -lt "$MAX_DELETES" ]; do
			OLDEST="$(find "$USB" -type f -name '*.jpg' -printf '$T@ %p\n' | sort -n | head -n 1 | cut -d' ' -f2-)"
			[ -z "$OLDEST" ] && break
			rm -f -- "$OLDEST"
			deletes=$((deletes + 1))
		done
		find "$USB" -type d -empty -delete || true
	fi
fi


