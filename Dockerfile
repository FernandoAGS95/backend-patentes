# Imagen Python oficial con Debian estable
FROM python:3.9-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV YOLO_CONFIG_DIR=/tmp

# Dependencias del sistema (Bullseye tiene las librerías que necesitas)
RUN apt-get update && apt-get install -y \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir numpy==1.24.4
RUN pip install --no-cache-dir torch==2.2.1 --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir torchvision==0.17.1 --index-url https://download.pytorch.org/whl/cpu   
RUN pip install --no-cache-dir opencv-python-headless==4.9.0.80
RUN pip install --no-cache-dir ultralytics==8.3.154
RUN pip install --no-cache-dir Pillow==11.2.1       
RUN pip install --no-cache-dir easyocr==1.7.2
RUN pip cache purge

# Node.js dependencies
COPY package.json .
RUN npm install --production --no-cache && npm cache clean --force

COPY server.js detect.py ./
RUN mkdir -p uploads
COPY runs/detect/train4/weights/best.pt ./model.pt
RUN mkdir -p /tmp && chmod 777 /tmp

EXPOSE $PORT
CMD ["node", "server.js"]