# --- Phase 1: Build OSXCross Toolchain & Base Environment ---
FROM ubuntu:22.04 AS xcompile-base

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install ALL Dependencies (Build-time and Runtime)
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
    rsync \
    ssh \
    zip \
    curl \
    jq \
    ripgrep \
    fd-find \
    tree \
    iputils-ping \
    file \
    && rm -rf /var/lib/apt/lists/*

# 2. Set up OSXCross
WORKDIR /osxcross
RUN git clone https://github.com/tpoechtrager/osxcross.git .

# 3. Add SDK Tarballs (Expected in cross-compile-system/tarballs/)
COPY cross-compile-system/tarballs/*.tar.gz /osxcross/tarballs/

# 4. Build the toolchain using the 10.10 SDK as the toolchain base
ENV UNATTENDED=1
ENV SDK_VERSION=10.10
RUN ./build.sh

# 5. Manually unpack ALL additional SDKs into the target directory
RUN mkdir -p target/SDKs && \
    for f in tarballs/*.tar.gz; do tar -C target/SDKs -xzf "$f"; done

# 6. Environment Setup
ENV PATH="/osxcross/target/bin:${PATH}"
ENV OSXCROSS_HOST="x86_64-apple-darwin14"
WORKDIR /app

# --- Phase 2: Gemini with Cross-Compilation Tools ---
FROM xcompile-base AS xcompile-gemini
ENV FORCE_COLOR=1

# Install Node.js (Required for Gemini)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Gemini CLI
RUN npm install -g @google/gemini-cli

# Default command
CMD ["gemini", "--yolo"]
