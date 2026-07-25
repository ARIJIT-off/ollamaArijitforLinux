#!/bin/bash
# =============================================================
# install.sh
# One-command installer for Arijitappmakinginjava (Linux)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main/install.sh | bash
# =============================================================
set -e

INSTALL_DIR="$HOME/.local/bin"
MODEL_TAG="arijitp203/Arijitjavacodes3b"
REPO_BASE="https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main"

echo ""
echo "====================================================="
echo " Arijitappmakinginjava - Linux Installer"
echo "====================================================="
echo ""

# ---------------------------------------------------------------
# Step 1: Check / install Ollama
# ---------------------------------------------------------------
echo "[1/5] Checking for Ollama..."
if ! command -v ollama >/dev/null 2>&1; then
    echo "      Ollama not found. Installing..."
    curl -fsSL https://ollama.com/install.sh | sh
    echo "      Ollama installed."
else
    echo "      Ollama already installed."
fi

# ---------------------------------------------------------------
# Step 2: Check / install JDK
# ---------------------------------------------------------------
echo ""
echo "[2/5] Checking for a JDK (javac)..."
if ! command -v javac >/dev/null 2>&1; then
    echo "      javac not found. Installing OpenJDK 21..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y openjdk-21-jdk
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y java-21-openjdk-devel
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm jdk-openjdk
    else
        echo "      Could not detect package manager. Please install a JDK 21 manually."
    fi
else
    echo "      JDK already installed."
fi

# ---------------------------------------------------------------
# Step 3: Pull the fine-tuned model
# ---------------------------------------------------------------
echo ""
echo "[3/5] Pulling model '$MODEL_TAG' (this is a large download, please wait)..."
if ollama pull "$MODEL_TAG"; then
    echo "      Model pulled successfully."
else
    echo "      Could not pull the model automatically. If Ollama was just installed,"
    echo "      open a new terminal and run: ollama pull $MODEL_TAG"
fi

# ---------------------------------------------------------------
# Step 4: Download the CLI script
# ---------------------------------------------------------------
echo ""
echo "[4/5] Downloading Arijitappmakinginjava CLI to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR"
curl -fsSL "$REPO_BASE/arijitappmakinginjava.sh" -o "$INSTALL_DIR/arijitappmakinginjava"
chmod +x "$INSTALL_DIR/arijitappmakinginjava"
echo "      CLI downloaded."

# Make sure ~/.local/bin is on PATH
SHELL_RC="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
fi
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "      Added $INSTALL_DIR to PATH in $SHELL_RC"
fi

# ---------------------------------------------------------------
# Step 5: Choose save location
# ---------------------------------------------------------------
echo ""
echo "[5/5] Choose where generated Java apps should be saved."
read -p "      Enter a folder path (or press Enter to use ~/ArijitJavaApps): " SAVE_PATH
if [ -z "$SAVE_PATH" ]; then
    SAVE_PATH="$HOME/ArijitJavaApps"
fi
mkdir -p "$SAVE_PATH"

CONFIG_DIR="$HOME/.arijitjavacodes"
mkdir -p "$CONFIG_DIR"
echo "{\"SavePath\": \"$SAVE_PATH\"}" > "$CONFIG_DIR/config.json"
echo "      Save path set to: $SAVE_PATH"

echo ""
echo "====================================================="
echo " Install complete!"
echo ""
echo " Close and reopen your terminal, then run:"
echo "   arijitappmakinginjava"
echo "====================================================="
echo ""
