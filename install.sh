#!/bin/bash
# =============================================================
# install.sh
#
# This is a magic setup script! It gets your computer ready
# to build Java apps just by asking for them.
#
# How to use it:
#   curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main/install.sh | bash
# =============================================================
set -e

INSTALL_DIR="$HOME/.local/bin"
MODEL_TAG="arijitp203/Arijitjavacodes3b"
REPO_BASE="https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main"
DEFAULT_SAVE_PATH="$HOME/ArijitJavaApps"

echo ""
echo "====================================================="
echo " Hi! Let's set up Arijit App Making in Java"
echo "====================================================="
echo " I'm going to do 5 things. Just wait and watch!"
echo ""

# ---------------------------------------------------------------
# STEP 1: Do we have "Ollama"? (the robot brain that writes code)
# ---------------------------------------------------------------
echo "[Step 1 of 5] Looking for the robot brain (Ollama)..."
OLLAMA_JUST_INSTALLED=false
if ! command -v ollama >/dev/null 2>&1; then
    echo "      Not found! Downloading it now, one sec..."
    curl -fsSL https://ollama.com/install.sh | sh
    OLLAMA_JUST_INSTALLED=true
    echo "      Yay, the robot brain is here!"
else
    echo "      Great, it's already here!"
fi

# ---------------------------------------------------------------
# STEP 2: Do we have a JDK? (the tool that understands Java)
# ---------------------------------------------------------------
echo ""
echo "[Step 2 of 5] Looking for the Java tool (JDK)..."
if ! command -v javac >/dev/null 2>&1; then
    echo "      Not found! Installing Java 21, please wait..."
    if command -v apt >/dev/null 2>&1; then
        if ! (sudo apt update && sudo apt install -y openjdk-21-jdk); then
            echo "      Oops, that didn't work. Ask a grown-up to install Java 21 for you."
        fi
    elif command -v dnf >/dev/null 2>&1; then
        if ! sudo dnf install -y java-21-openjdk-devel; then
            echo "      Oops, that didn't work. Ask a grown-up to install Java 21 for you."
        fi
    elif command -v pacman >/dev/null 2>&1; then
        if ! sudo pacman -S --noconfirm jdk-openjdk; then
            echo "      Oops, that didn't work. Ask a grown-up to install Java 21 for you."
        fi
    else
        echo "      I couldn't figure out how to install it. Ask a grown-up for help."
    fi
else
    echo "      Great, it's already here!"
fi

# ---------------------------------------------------------------
# STEP 3: Download the special "brain" that knows how to write Java
# ---------------------------------------------------------------
echo ""
echo "[Step 3 of 5] Downloading the Java-writing brain (this is big, be patient!)..."

if [ "$OLLAMA_JUST_INSTALLED" = true ]; then
    echo "      Waking up the robot brain..."
    ollama serve >/tmp/ollama_serve.log 2>&1 &
    for i in $(seq 1 20); do
        if curl -fsS http://127.0.0.1:11434 >/dev/null 2>&1; then
            break
        fi
        sleep 0.5
    done
fi

if ollama pull "$MODEL_TAG"; then
    echo "      All done! The brain is ready to write Java code."
else
    echo "      Hmm, that didn't work. Try closing this window, opening a new one,"
    echo "      and typing: ollama pull $MODEL_TAG"
fi

# ---------------------------------------------------------------
# STEP 4: Get the tool you'll actually type commands into
# ---------------------------------------------------------------
echo ""
echo "[Step 4 of 5] Getting your app-building tool ready..."
mkdir -p "$INSTALL_DIR"
curl -fsSL "$REPO_BASE/arijitappmakinginjava.sh" -o "$INSTALL_DIR/arijitappmakinginjava"
chmod +x "$INSTALL_DIR/arijitappmakinginjava"
echo "      Got it!"

SHELL_RC="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
fi
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "      One-time setup done so your computer can find the tool."
fi

# ---------------------------------------------------------------
# STEP 5: Where should your new apps be saved?
# ---------------------------------------------------------------
echo ""
echo "[Step 5 of 5] Where do you want your new apps saved?"
echo "      (Tip: just press Enter to use the easy default spot!)"
read -p "      Type a folder name, or press Enter: " SAVE_PATH </dev/tty

if [ -z "$SAVE_PATH" ]; then
    SAVE_PATH="$DEFAULT_SAVE_PATH"
fi

# If they typed something starting with ~ (like ~/Downloads), fix it up
case "$SAVE_PATH" in
    "~"*) SAVE_PATH="${HOME}${SAVE_PATH#\~}" ;;
esac

if ! mkdir -p "$SAVE_PATH" 2>/dev/null; then
    echo "      Oops, I can't save apps there (maybe it needs a grown-up's permission)."
    echo "      No worries — I'll use the easy default spot instead: $DEFAULT_SAVE_PATH"
    SAVE_PATH="$DEFAULT_SAVE_PATH"
    mkdir -p "$SAVE_PATH"
fi

CONFIG_DIR="$HOME/.arijitjavacodes"
mkdir -p "$CONFIG_DIR"
echo "{\"SavePath\": \"$SAVE_PATH\"}" > "$CONFIG_DIR/config.json"
echo "      Your apps will be saved here: $SAVE_PATH"

echo ""
echo "====================================================="
echo " All done! You're ready to build Java apps!"
echo ""
echo " Close this window, open a new one, and type:"
echo "   arijitappmakinginjava"
echo "====================================================="
echo ""
