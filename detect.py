import sys
import json
from ultralytics import YOLO
import cv2
import easyocr
import os
import contextlib

# 🔥 SILENCIO TOTAL - Redireccionar stdout/stderr a null
with open(os.devnull, 'w') as f:
    with contextlib.redirect_stdout(f), contextlib.redirect_stderr(f):
        # 🔥 Desactivar TODOS los logs de YOLO y dependencias
        os.environ['YOLO_VERBOSE'] = 'False'
        os.environ['ULTRALYTICS_VERBOSE'] = 'False'
        os.environ['EASYOCR_VERBOSE'] = 'False'
        
        # 🔥 Cargar modelo en SILENCIO ABSOLUTO
        model = YOLO("./model.pt")
        reader = easyocr.Reader(["en"])

# Imagen de entrada
image_path = sys.argv[1]

# 🔥 Ejecutar detección en SILENCIO ABSOLUTO
with open(os.devnull, 'w') as f:
    with contextlib.redirect_stdout(f), contextlib.redirect_stderr(f):
        results = model(image_path, verbose=False)

# Leer imagen (esto no genera logs)
img = cv2.imread(image_path)

plate = None

# Procesar detecciones
for r in results:
    boxes = r.boxes.xyxy.cpu().numpy()

    for (x1, y1, x2, y2) in boxes:
        x1, y1, x2, y2 = map(int, [x1, y1, x2, y2])
        crop = img[y1:y2, x1:x2]

        if crop.size == 0:
            continue

        # 🔥 EasyOCR también en SILENCIO
        with open(os.devnull, 'w') as f:
            with contextlib.redirect_stdout(f), contextlib.redirect_stderr(f):
                text = reader.readtext(crop, detail=0)
        
        if text:
            plate = text[0]
            break
    if plate:
        break

# 🔥 Imprimir SOLO JSON limpio (esto es lo ÚNICO que se verá)
print(json.dumps({"plate": plate if plate else "NO_PLATE"}), flush=True)

sys.exit(0)