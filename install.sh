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
JDK_VERSION="19"
SDKMAN_JAVA_CANDIDATE="19.0.2-tem"

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
# Step 2: Check / install JDK 19 specifically
# ---------------------------------------------------------------
echo ""
echo "[2/5] Checking for JDK $JDK_VERSION (javac)..."

CURRENT_JAVA_VERSION=""
if command -v javac >/dev/null 2>&1; then
    CURRENT_JAVA_VERSION=$(javac -version 2>&1 | awk '{print $2}' | cut -d'.' -f1)
fi

if [ "$CURRENT_JAVA_VERSION" = "$JDK_VERSION" ]; then
    echo "      JDK $JDK_VERSION already installed."
else
    if [ -n "$CURRENT_JAVA_VERSION" ]; then
        echo "      Found JDK $CURRENT_JAVA_VERSION, but JDK $JDK_VERSION is required. Installing JDK $JDK_VERSION alongside it..."
    else
        echo "      No JDK found. Installing JDK $JDK_VERSION..."
    fi

    JDK_INSTALLED=false

    # Try the distro package manager first (works if the distro hasn't pruned JDK 19 yet)
    if command -v apt >/dev/null 2>&1; then
        if sudo apt update && sudo apt install -y "openjdk-${JDK_VERSION}-jdk" 2>/dev/null; then
            JDK_INSTALLED=true
        fi
    elif command -v dnf >/dev/null 2>&1; then
        if sudo dnf install -y "java-${JDK_VERSION}-openjdk-devel" 2>/dev/null; then
            JDK_INSTALLED=true
        fi
    elif command -v pacman >/dev/null 2>&1; then
        if sudo pacman -S --noconfirm "jdk${JDK_VERSION}-openjdk" 2>/dev/null; then
            JDK_INSTALLED=true
        fi
    fi

    # Fallback: JDK 19 is EOL and usually pruned from distro repos and Adoptium's
    # /latest/ endpoint. SDKMAN keeps a long-term candidate archive, so use that.
    if [ "$JDK_INSTALLED" != "true" ]; then
        echo "      Package manager does not have JDK $JDK_VERSION (likely removed since it's EOL)."
        echo "      Falling back to SDKMAN to install JDK $JDK_VERSION..."

        if [ ! -d "$HOME/.sdkman" ]; then
            curl -s "https://get.sdkman.io" | bash
        fi

        # shellcheck disable=SC1090
        source "$HOME/.sdkman/bin/sdkman-init.sh"

        if sdk install java "$SDKMAN_JAVA_CANDIDATE" < /dev/null; then
            JDK_INSTALLED=true
            echo "      JDK $JDK_VERSION installed via SDKMAN ($SDKMAN_JAVA_CANDIDATE)."

            SHELL_RC="$HOME/.bashrc"
            if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
                SHELL_RC="$HOME/.zshrc"
            fi
            if ! grep -q "sdkman-init.sh" "$SHELL_RC" 2>/dev/null; then
                {
                    echo "export SDKMAN_DIR=\"$HOME/.sdkman\""
                    echo "[[ -s \"$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"$HOME/.sdkman/bin/sdkman-init.sh\""
                } >> "$SHELL_RC"
                echo "      Added SDKMAN init to $SHELL_RC"
            fi
        else
            echo "      SDKMAN install of JDK $JDK_VERSION failed."
            echo "      Please install it manually, e.g.:"
            echo "        curl -s \"https://get.sdkman.io\" | bash"
            echo "        source \"\$HOME/.sdkman/bin/sdkman-init.sh\""
            echo "        sdk install java $SDKMAN_JAVA_CANDIDATE"
        fi
    else
        echo "      JDK $JDK_VERSION installed via package manager."
    fi
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
read -p "      Enter a folder path (or press Enter to use ~/ArijitJavaApps): " SAVE_PATH </dev/tty
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
