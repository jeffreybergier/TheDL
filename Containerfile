# --- Phase 1: Build OSXCross Toolchain ---
FROM ubuntu:22.04 AS xcompile-base

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Build Dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    llvm-dev \
    libxml2-dev \
    uuid-dev \
    libssl-dev \
    bash \
    patch \
    make \
    tar \
    xz-utils \
    bzip2 \
    gzip \
    git \
    python3 \
    python3-distutils \
    cpio \
    libz-dev \
    cmake \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Set up OSXCross
WORKDIR /osxcross
RUN git clone https://github.com/tpoechtrager/osxcross.git .

# 3. Add SDK Tarballs
COPY cross-compile-system/tarballs/*.tar.gz /osxcross/tarballs/

# 4. Build the toolchain using the 10.10 SDK as the toolchain base
ENV UNATTENDED=1
ENV SDK_VERSION=10.10
RUN ./build.sh

# 5. Manually unpack additional SDKs into the target directory
# OSXCross expects them in /osxcross/target/SDKs/
RUN mkdir -p target/SDKs && \
    tar -C target/SDKs -xzf tarballs/iPhoneOS8.2.sdk.tar.gz && \
    tar -C target/SDKs -xzf tarballs/iPhoneSimulator8.2.sdk.tar.gz && \
    tar -C target/SDKs -xzf tarballs/MacOSX10.4u.sdk.tar.gz && \
    tar -C target/SDKs -xzf tarballs/MacOSX10.6.sdk.tar.gz

# --- Standard Gemini (Original Version / Fallback) ---
FROM node:20-slim AS plain-gemini
EXPOSE 3000
ENV FORCE_COLOR=1
RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN npm install -g @google/gemini-cli
COPY . .

# --- Gemini with Cross-Compilation Tools ---
FROM node:20-slim AS xcompile-gemini

# Install Gemini CLI and Runtime Build Tools
ENV FORCE_COLOR=1
RUN apt-get update && apt-get install -y \
    curl \
    git \
    make \
    clang \
    libxml2 \
    openssl \
    python3 \
    zip \
    ssh \
    && rm -rf /var/lib/apt/lists/*

# Install Gemini CLI
RUN npm install -g @google/gemini-cli

# Copy OSXCross toolchain from builder
COPY --from=xcompile-base /osxcross/target /osxcross/target

# Set up Environment
ENV PATH="/osxcross/target/bin:${PATH}"
ENV OSXCROSS_HOST="x86_64-apple-darwin14"
WORKDIR /app

# Final Copy
COPY . .