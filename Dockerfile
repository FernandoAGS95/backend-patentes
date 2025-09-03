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

# Python dependencies (versiones compatibles comprobadas)
RUN pip install --upgrade pip

# Instalar NumPy PRIMERO con versión estable
RUN pip install --no-cache-dir "numpy>=1.21.0,<1.25.0"

# PyTorch con versión compatible con NumPy
RUN pip install --no-cache-dir torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cpu

# Instalar resto de dependencias con versiones compatibles
RUN pip install --no-cache-dir opencv-python-headless==4.8.1.78
RUN pip install --no-cache-dir "ultralytics>=8.0.0,<8.1.0"
RUN pip install --no-cache-dir "Pillow>=9.0.0,<11.0.0"       
RUN pip install --no-cache-dir "easyocr>=1.6.0,<1.8.0"

# Verificar instalación
RUN python -c "import numpy; import torch; print(f'NumPy: {numpy.__version__}'); print(f'PyTorch: {torch.__version__}')"

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