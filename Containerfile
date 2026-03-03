## Instructions

# For handy shortcuts see compose.yml

# Build
# docker build -f Containerfile --target gemini -t thedl-gemini .

# Run Gemini
# docker run -it --rm -v "$(pwd):/app" -v ~/.gemini:/root/.gemini thedl-gemini gemini

# --- Gemini ---
FROM node:20-slim AS gemini
EXPOSE 3000
ENV FORCE_COLOR=1
RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# 1. Gemini
RUN npm install -g @google/gemini-cli

# 3. Source Code
COPY . .
