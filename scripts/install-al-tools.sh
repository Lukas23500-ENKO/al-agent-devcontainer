#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# install-al-tools.sh
# Runs once after the Dev Container is created (postCreateCommand).
# Installs and configures all AL development tooling inside the container.
# ─────────────────────────────────────────────────────────────────────────────

set -e  # Exit on any error

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ENKO AL Dev Container — Tool Setup"
echo "════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
# 1. Verify required tools are present
# ─────────────────────────────────────────────
echo "▶ Verifying base tools..."

check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo "  ✗ $1 not found — check Dockerfile"
    exit 1
  else
    echo "  ✓ $1 $(${2:-$1 --version} 2>&1 | head -1)"
  fi
}

check_tool "node" "node --version"
check_tool "npm" "npm --version"
check_tool "claude" "claude --version"
check_tool "pwsh" "pwsh --version"
check_tool "git" "git --version"

echo ""

# ─────────────────────────────────────────────
# 2. Configure Git inside container
# ─────────────────────────────────────────────
echo "▶ Configuring Git..."

# Use host gitconfig if mounted — otherwise set defaults
if [ -f "/home/vscode/.gitconfig" ]; then
  echo "  ✓ Host .gitconfig detected — using host Git identity"
else
  echo "  ⚠ No host .gitconfig found — set Git identity manually:"
  echo "    git config --global user.name 'Your Name'"
  echo "    git config --global user.email 'your@email.com'"
fi

# AL-specific Git settings
git config --global core.autocrlf input
git config --global core.eol lf
git config --global push.autoSetupRemote true

echo "  ✓ Git configured (autocrlf=input, eol=lf)"
echo ""

# ─────────────────────────────────────────────
# 3. Install PowerShell modules
# ─────────────────────────────────────────────
echo "▶ Installing PowerShell modules..."

pwsh -NonInteractive -Command "
  \$ErrorActionPreference = 'Stop'

  # Set PSGallery as trusted
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

  # Install modules
  \$modules = @(
    'Pester'          # AL test runner support
  )

  foreach (\$module in \$modules) {
    if (-not (Get-Module -ListAvailable -Name \$module)) {
      Write-Host \"  Installing \$module...\"
      Install-Module -Name \$module -Scope CurrentUser -Force -AllowClobber
      Write-Host \"  ✓ \$module installed\"
    } else {
      Write-Host \"  ✓ \$module already installed\"
    }
  }
"

echo ""

# ─────────────────────────────────────────────
# 4. Create workspace folder structure
# ─────────────────────────────────────────────
echo "▶ Setting up workspace..."

# Create .alpackages directory if not present
if [ ! -d "/workspace/.alpackages" ]; then
  mkdir -p /workspace/.alpackages
  echo "  ✓ .alpackages directory created"
else
  echo "  ✓ .alpackages directory exists"
fi

echo ""

# ─────────────────────────────────────────────
# 5. Verify Claude Code authentication
# ─────────────────────────────────────────────
echo "▶ Checking Claude Code authentication..."

if claude auth status &> /dev/null; then
  echo "  ✓ Claude Code authenticated"
else
  echo "  ⚠ Claude Code not authenticated"
  echo "    Run: claude login"
fi

echo ""

# ─────────────────────────────────────────────
# 6. Print summary
# ─────────────────────────────────────────────
echo "════════════════════════════════════════════════════════"
echo "  Setup complete"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo "  1. If Claude Code is not authenticated: claude login"
echo "  2. Open your AL project workspace"
echo "  3. Run: pwsh scripts/validate-launch-config.ps1"
echo "  4. Start Claude Code: claude"
echo ""
