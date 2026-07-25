#!/bin/bash
# =============================================================
# install.sh
# One-command installer for Arijitappmakinginjava (Linux/macOS)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main/install.sh | bash
# =============================================================

set -e

INSTALL_DIR="$HOME/.arijitappmakinginjava"
MODEL_TAG="arijitp203/Arijitjavacodes3b"
REPO_BASE="https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main"
BIN_DIR="$HOME/.local/bin"

echo ""
echo "====================================================="
echo " Arijitappmakinginjava - Linux Installer"
echo "====================================================="
echo ""

# ---------------------------------------------------------------
# Step 1: Check / install Ollama
# ---------------------------------------------------------------
echo "[1/6] Checking for Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "      Ollama not found. Installing..."
    curl -fsSL https://ollama.ai/install.sh | sh
    echo "      Ollama installed. Starting service..."
    sudo systemctl start ollama || true
    sleep 2
    echo "      Ollama running."
else
    echo "      Ollama already installed."
fi

# ---------------------------------------------------------------
# Step 2: Check / install JDK
# ---------------------------------------------------------------
echo ""
echo "[2/6] Checking for a JDK (javac)..."
if ! command -v javac &> /dev/null; then
    echo "      javac not found. Installing OpenJDK 21..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y openjdk-21-jdk
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y java-21-openjdk-devel
    elif command -v brew &> /dev/null; then
        brew install openjdk@21
        sudo ln -sfn $(brew --prefix)/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
    else
        echo "      Could not auto-detect package manager. Please install OpenJDK 21 manually."
        exit 1
    fi
    echo "      JDK installed."
else
    echo "      JDK already installed."
fi

# ---------------------------------------------------------------
# Step 3: Pull the fine-tuned model
# ---------------------------------------------------------------
echo ""
echo "[3/6] Pulling model '$MODEL_TAG' (this is a large download, please wait)..."
ollama pull "$MODEL_TAG"
echo "      Model pulled successfully."

# ---------------------------------------------------------------
# Step 4: Download the CLI script
# ---------------------------------------------------------------
echo ""
echo "[4/6] Downloading Arijitappmakinginjava CLI..."
mkdir -p "$INSTALL_DIR"
curl -fsSL "$REPO_BASE/arijitappmakinginjava.sh" -o "$INSTALL_DIR/arijitappmakinginjava.sh"
chmod +x "$INSTALL_DIR/arijitappmakinginjava.sh"
echo "      CLI downloaded."

# ---------------------------------------------------------------
# Step 5: Set up bin directory and symlink
# ---------------------------------------------------------------
echo ""
echo "[5/6] Setting up command-line access..."
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/arijitappmakinginjava.sh" "$BIN_DIR/arijitappmakinginjava"

# Check if $BIN_DIR is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "      Adding $BIN_DIR to PATH..."
    if [ -f "$HOME/.bashrc" ]; then
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$HOME/.bashrc"
    fi
    if [ -f "$HOME/.zshrc" ]; then
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$HOME/.zshrc"
    fi
    export PATH="$BIN_DIR:$PATH"
    echo "      PATH updated. Please restart your terminal or run: source ~/.bashrc"
else
    echo "      $BIN_DIR already in PATH."
fi

# ---------------------------------------------------------------
# Step 6: Ask for save location
# ---------------------------------------------------------------
echo ""
echo "[6/6] Choose where generated Java apps should be saved."
read -p "      Enter a folder path (or press Enter for ~/java_apps): " SAVE_PATH
SAVE_PATH="${SAVE_PATH:-$HOME/java_apps}"
mkdir -p "$SAVE_PATH"

# Store config
mkdir -p "$INSTALL_DIR/.config"
cat > "$INSTALL_DIR/.config/config.json" <<EOF
{
  "savePath": "$SAVE_PATH",
  "modelTag": "$MODEL_TAG"
}
EOF
echo "      Save path set to: $SAVE_PATH"

# ---------------------------------------------------------------
# Done
# ---------------------------------------------------------------
echo ""
echo "====================================================="
echo " Install complete!"
echo ""
echo " Restart your terminal, then run:"
echo "    arijitappmakinginjava"
echo "====================================================="
echo ""
