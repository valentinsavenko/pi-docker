# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

# === System dependencies + Node.js (LTS) ===
RUN apt-get update && apt-get install -y \
    curl git ca-certificates gnupg sudo xz-utils \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# === Install Zellij (Manually from GitHub) ===
RUN ARCH=$(uname -m) && \
    curl -L "https://github.com/zellij-org/zellij/releases/latest/download/zellij-$ARCH-unknown-linux-musl.tar.gz" | tar -xz && \
    install -m 755 zellij /usr/local/bin/zellij && \
    rm zellij

# Make sudo work without password for root
RUN echo "root ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/root

# === Install Pi coding agent ===
RUN npm install -g @mariozechner/pi-coding-agent

# Create Pi directories + workspace
RUN mkdir -p /root/.pi/agent/{extensions,skills} /workspace

# === Install extensions & skills ===
RUN pi install npm:mitsupi
RUN pi install npm:pi-teams

# Clean up
RUN rm -rf /tmp/*

# === Entry point — Now with Zellij integration ===
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'echo "✅ Pi agent environment ready"' >> /entrypoint.sh && \
    echo 'echo "   Starting Zellij..."' >> /entrypoint.sh && \
    echo 'exec zellij --session pi-session attach --create options --default-shell /bin/bash ' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

WORKDIR /workspace

# Zellij needs a proper TERM variable for its UI
ENV TERM=xterm-256color

ENTRYPOINT ["/entrypoint.sh"]