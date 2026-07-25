#!/bin/bash

# Configuration directories
INSTALL_DIR="$HOME/.arijitappmakinginjava"
CONFIG_FILE="$INSTALL_DIR/.config/config.json"

# Load configuration if available
if [ -f "$CONFIG_FILE" ]; then
    SAVE_PATH=$(grep -o '"savePath"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed 's/.*"//')
    MODEL_TAG=$(grep -o '"modelTag"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed 's/.*"//')
fi

# Fallback defaults
SAVE_PATH="${SAVE_PATH:-$HOME/java_apps}"
MODEL_TAG="${MODEL_TAG:-arijitp203/Arijitjavacodes3b}"

clear
cat << "EOF"
    _    ____  ___    _ ___ _____ 
   / \   |  _ \|_ _|  | |_ _|_   _|
  / _ \  | |_) || |_   | || |  | |  
 / ___ \ |  _ < | | |_| || |  | |  
/_/   \_\_| \_\___\___/|___| |_|  

    A R I J I T   A P P   M A K I N G   I N   J A V A
    -------------------------------------------------
    Local vibe-coding, zero cloud, zero rate limits.
    Unlike other LLMs -> NO RATE LIMITS. Ask as much as you want.

    Model in use : $MODEL_TAG
    Apps saved to: $SAVE_PATH

    =================================================
    COMMANDS
    A                 - start a new app-building session
    setpath <path>    - change where apps get saved
    exit              - quit this tool
    =================================================
EOF
echo ""

# Current working app tracker
CURRENT_APP_NAME=""

while true; do
    read -p "> " cmd
    
    case "$cmd" in
        [Aa])
            echo ""
            echo "Ask anything, I will build it."
            echo "(Type 'Finish' at any point to end this session.)"
            echo ""
            
            while true; do
                read -p "You: " user_input
                
                if [ "$user_input" = "Finish" ] || [ "$user_input" = "finish" ]; then
                    echo "Session ended."
                    break
                elif [ "$user_input" = "run" ] || [ "$user_input" = "RUN" ]; then
                    if [ -z "$CURRENT_APP_NAME" ]; then
                        echo ">> No app has been generated yet to run!"
                    else
                        echo ">> Compiling $CURRENT_APP_NAME.java..."
                        if javac "$SAVE_PATH/$CURRENT_APP_NAME.java"; then
                            echo ">> Compilation successful! Running..."
                            java -cp "$SAVE_PATH" "$CURRENT_APP_NAME"
                        else
                            echo ">> Compilation failed. Paste the error back here and I'll fix it!"
                        fi
                    fi
                else
                    echo ""
                    echo ">> Building..."
                    
                    # Ask Ollama and capture output
                    raw_response=$(ollama run "$MODEL_TAG" "$user_input")
                    
                    # Try to intelligently guess a class name from the prompt or default to MainApp
                    CURRENT_APP_NAME="GeneratedApp"
                    if echo "$user_input" | grep -qi "calculator"; then
                        CURRENT_APP_NAME="Calculator"
                    elif echo "$user_input" | grep -qi "notepad" || echo "$user_input" | grep -qi "editor"; then
                        CURRENT_APP_NAME="NotepadApp"
                    fi
                    
                    # Ensure save directory exists
                    mkdir -p "$SAVE_PATH"
                    
                    # Save response content into the java file
                    echo "$raw_response" > "$SAVE_PATH/$CURRENT_APP_NAME.java"
                    
                    echo ""
                    echo "$raw_response"
                    echo ""
                    echo ">> Saved to: $SAVE_PATH/$CURRENT_APP_NAME.java"
                    echo ""
                    echo "Any issues? tell me, I will code accordingly."
                    echo "(or type 'run' to compile and run it, or 'Finish' to end)"
                fi
            done
            ;;
            
        setpath*)
            new_path=$(echo "$cmd" | sed 's/setpath[[:space:]]*//')
            if [ -n "$new_path" ]; then
                SAVE_PATH="$new_path"
                mkdir -p "$SAVE_PATH"
                mkdir -p "$INSTALL_DIR/.config"
                cat > "$CONFIG_FILE" <<EOF
{
  "savePath": "$SAVE_PATH",
  "modelTag": "$MODEL_TAG"
}
EOF
                echo ">> Save path updated to: $SAVE_PATH"
            else
                echo ">> Usage: setpath /your/path/here"
            fi
            ;;
            
        exit|QUIT)
            echo "Goodbye!"
            exit 0
            ;;
            
        *)
            if [ -n "$cmd" ]; then
                echo "Unknown command. Type 'A' to start building or 'exit' to quit."
            fi
            ;;
    esac
done
