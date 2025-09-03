# Usar imagen más pequeña
FROM python:3.9-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV YOLO_CONFIG_DIR=/tmp

# Solo dependencias críticas
RUN apt-get update && apt-get install -y \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgcc-s1 \
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

# Instalar NumPy PRIMERO con versión compatible
RUN pip install --no-cache-dir numpy==1.24.4

# Instalar dependencias Python una por una (más control)
RUN pip install --no-cache-dir torch==2.2.1 --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir torchvision==0.17.1 --index-url https://download.pytorch.org/whl/cpu   
RUN pip install --no-cache-dir opencv-python-headless==4.9.0.80
RUN pip install --no-cache-dir Pillow==11.2.1       
RUN pip install --no-cache-dir ultralytics==8.3.154
RUN pip install --no-cache-dir easyocr==1.7.2

# Limpiar cache de pip
RUN pip cache purge

# Copiar solo archivos necesarios
COPY package.json .
RUN npm install --production --no-cache && npm cache clean --force

COPY server.js detect.py ./
RUN mkdir -p uploads

# Copiar modelo YOLO al final (mejor cache)
COPY runs/detect/train4/weights/best.pt ./model.pt

# Crear directorio temporal para YOLO
RUN mkdir -p /tmp && chmod 777 /tmp

EXPOSE $PORT
CMD ["node", "server.js"]