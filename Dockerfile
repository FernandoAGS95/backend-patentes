FROM python:3.9-slim

# Solo lo esencial
RUN apt-get update && apt-get install -y \
    curl \
    libglib2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

WORKDIR /app

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Node dependencies  
COPY package.json .
RUN npm install

# App files
COPY . .

# Create uploads dir
RUN mkdir -p uploads

EXPOSE $PORT
CMD ["node", "server.js"]