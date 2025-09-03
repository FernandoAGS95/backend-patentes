# Usar imagen más pequeña
FROM python:3.9-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Solo dependencias críticas
RUN apt-get update && apt-get install -y \
    curl \
    libglib2.0-0 \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Node.js (versión más liviana)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Actualizar pip
RUN pip install --no-cache-dir --upgrade pip

# Instalar dependencias Python una por una (más control)
RUN pip install --no-cache-dir torch==2.0.1 --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cpu  
RUN pip install --no-cache-dir opencv-python-headless==4.8.1.78
RUN pip install --no-cache-dir ultralytics==8.0.196
RUN pip install --no-cache-dir easyocr==1.7.0
RUN pip install --no-cache-dir numpy==1.24.3 Pillow==10.0.0

# Limpiar cache de pip
RUN pip cache purge

# Copiar solo archivos necesarios
COPY package.json .
RUN npm install --production --no-cache && npm cache clean --force

COPY server.js detect.py ./
RUN mkdir -p uploads

# Copiar modelo YOLO al final (mejor cache)
COPY runs/detect/train4/weights/best.pt ./model.pt

# Modificar detect.py para usar el modelo en la raíz
# (tendrás que cambiar la ruta en detect.py)

EXPOSE $PORT
CMD ["node", "server.js"]