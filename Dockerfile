FROM python:3.9-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgthread-2.0-0 \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar archivos Python
COPY requirements.txt .
COPY detect.py .

# Instalar dependencias Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar archivos Node.js
COPY package.json .
COPY server.js .

# Instalar dependencias Node.js
RUN npm install

# Crear directorio uploads
RUN mkdir -p uploads

# Copiar modelo YOLO
COPY runs/ ./runs/

EXPOSE $PORT

CMD ["node", "server.js"]