#!/bin/bash
set -euo pipefail

# Only run in remote (web) environment
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Check if Quarto is already installed
if command -v quarto &> /dev/null; then
  echo "Quarto is already installed: $(quarto --version)"
  exit 0
fi

echo "Installing Quarto..."

# Install Quarto - using a stable release
QUARTO_VERSION="1.4.557"
QUARTO_DEB="quarto-${QUARTO_VERSION}-linux-amd64.deb"
QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/${QUARTO_DEB}"

# Download and install
cd /tmp
curl -fsSL -o "${QUARTO_DEB}" "${QUARTO_URL}"
dpkg -i "${QUARTO_DEB}" || apt-get install -f -y
rm -f "${QUARTO_DEB}"

# Verify installation
quarto --version
echo "Quarto installation complete"
