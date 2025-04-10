#!/bin/bash
set -e

echo "🔧 Starting setup..."

# Step 1: Detect OS
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
  elif [ "$(uname)" == "Darwin" ]; then
    OS="macos"
  else
    OS="unknown"
  fi
  echo "🧠 Detected OS: $OS"
  echo "$OS" > .os_type
}

detect_os

# Step 2: Use OS to install packages
case "$OS" in
  ubuntu|debian)
    echo "📦 Installing dependencies with apt..."
    #sudo apt update
    #sudo apt install -y curl git ffuf
    ;;
  macos)
    chmod -R +x Digiscan/; cd Digiscan; cd scanner; chmod +x ttab; sudo mv ttab /usr/local/bin/; cd ~/Digiscan/scanner; ./scanner_met_menu.sh
    ;;
  *)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "✅ Setup complete. Use ./scanner_met_menu.sh to start."
