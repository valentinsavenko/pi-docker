# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

# === System dependencies + Node.js (LTS) ===
RUN apt-get update && apt-get install -y \
    curl git ca-certificates gnupg sudo \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Make sudo work without password for root
RUN echo "root ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/root

# === Install Pi coding agent ===
RUN npm install -g @mariozechner/pi-coding-agent

# Create Pi directories + workspace
RUN mkdir -p /root/.pi/agent/{extensions,skills} /workspace

# === Install ONLY non-conflicting recommended extensions & skills ===
# 1. Main bundle (includes loop, multi-edit, uv, review, todos, etc.)
RUN pi install npm:mitsupi

# 2. Official skills (brave-search, browser-tools, vscode, etc.)
RUN pi install git:https://github.com/badlogic/pi-skills

# 3. Advanced iterative/long-running loops (ralph-wiggum)
RUN pi install npm:@tmustier/pi-ralph-wiggum

# 4. Security (filter-output + dangerous command protection)
RUN git clone https://github.com/michalvavra/agents.git /tmp/michal-agents \
    && ln -sf /tmp/michal-agents/agents/pi/extensions/* /root/.pi/agent/extensions/ 2>/dev/null || true

# 5. teams/ agents
RUN pi install npm:pi-teams

# Clean up
RUN rm -rf /tmp/*

# === Entry point — clean startup messages ===
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'echo "✅ Pi agent started as root"' >> /entrypoint.sh && \
    echo 'echo "   Extensions loaded: mitsupi (loop + multi-edit + uv), official skills, ralph-wiggum, security"' >> /entrypoint.sh && \
    echo 'echo "   API keys passed via Docker -e (OPENROUTER_API_KEY is ready)"' >> /entrypoint.sh && \
    echo 'echo "   Working directory: /workspace (your project is mounted here)"' >> /entrypoint.sh && \
    echo 'echo "   → Starting interactive Pi TUI..."' >> /entrypoint.sh && \
    echo 'exec pi "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]