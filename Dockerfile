# Usar una versión estable de Python
FROM python:3.9-slim-bullseye

# Variables de entorno para evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Actualizar lista de paquetes e instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    # Dependencias para OpenCV
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgthread-2.0-0 \
    libgtk-3-0 \
    libavcodec58 \
    libavformat58 \
    libswscale5 \
    # Dependencias adicionales para OpenCV
    libgl1-mesa-dev \
    libglib2.0-dev \
    # Herramientas de compilación
    build-essential \
    cmake \
    pkg-config \
    # Dependencias de imágenes
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    # Curl para Node.js
    curl \
    # Limpiar caché
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Establecer directorio de trabajo
WORKDIR /app

# Copiar requirements.txt e instalar dependencias de Python
COPY requirements.txt .

# Actualizar pip e instalar dependencias Python
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copiar package.json e instalar dependencias de Node.js
COPY package.json .
RUN npm install --production

# Copiar archivos del proyecto
COPY detect.py .
COPY server.js .

# Crear directorio uploads
RUN mkdir -p uploads

# Copiar el modelo YOLO (asegúrate de que la ruta sea correcta)
COPY runs/ ./runs/

# Cambiar permisos
RUN chmod +x detect.py server.js

# Exponer el puerto (Railway usa la variable PORT)
EXPOSE $PORT

# Comando para iniciar la aplicación
CMD ["node", "server.js"]