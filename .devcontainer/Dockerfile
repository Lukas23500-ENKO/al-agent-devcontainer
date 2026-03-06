# ENKO AL Development Container
# Base: Microsoft Dev Container Ubuntu 22.04 LTS
# Includes: Claude Code, PowerShell 7, Node.js LTS, Git, AL tooling

FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# ─────────────────────────────────────────────
# 1. System packages
# ─────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────
# 2. Node.js LTS (required by Claude Code)
# ─────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify Node.js installation
RUN node --version && npm --version

# ─────────────────────────────────────────────
# 3. Claude Code CLI
# ─────────────────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code

# Verify Claude Code installation
RUN claude --version

# ─────────────────────────────────────────────
# 4. PowerShell 7 (LTS)
# ─────────────────────────────────────────────
RUN wget -q "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify PowerShell installation
RUN pwsh --version

# ─────────────────────────────────────────────
# 5. Git configuration defaults
# ─────────────────────────────────────────────
RUN git config --system core.autocrlf input \
    && git config --system core.eol lf

# ─────────────────────────────────────────────
# 6. Create workspace directory
# ─────────────────────────────────────────────
RUN mkdir -p /workspace \
    && chown vscode:vscode /workspace

# ─────────────────────────────────────────────
# 7. Switch to non-root user (vscode)
# ─────────────────────────────────────────────
USER vscode

# ─────────────────────────────────────────────
# 8. Claude Code config directory
# ─────────────────────────────────────────────
RUN mkdir -p /home/vscode/.claude

# ─────────────────────────────────────────────
# Metadata
# ─────────────────────────────────────────────
LABEL maintainer="ENKO Software" \
      description="BC AL Development Container with Claude Code" \
      base="ubuntu-22.04" \
      claudecode="2.x" \
      powershell="7.x"
