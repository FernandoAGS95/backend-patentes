import sys
import json
from ultralytics import YOLO
import cv2
import easyocr

# Cargar modelo YOLO
model = YOLO("./runs/detect/train4/weights/best.pt")
reader = easyocr.Reader(["en"])

# Imagen de entrada
image_path = sys.argv[1]

# Ejecutar detección sin logs en stdout
results = model(image_path, verbose=False)

# Leer solo una vez la imagen
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

        text = reader.readtext(crop, detail=0)
        if text:
            plate = text[0]
            break
    if plate:
        break

# 🔥 Imprimir SOLO JSON limpio
print(json.dumps({"plate": plate if plate else "NO_PLATE"}), flush=True)

sys.exit(0)
