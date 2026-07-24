#!/bin/bash
# =============================================================
# arijitappmakinginjava.sh
# Linux/macOS CLI for Arijitappmakinginjava
#
# Local Java Swing app generator powered by fine-tuned Qwen
# =============================================================

set -e

INSTALL_DIR="$HOME/.arijitappmakinginjava"
CONFIG_FILE="$INSTALL_DIR/.config/config.json"
MODEL_TAG="arijitp203/Arijitjavacodes3b"
SAVE_PATH="$HOME/java_apps"

# Load config if it exists
if [ -f "$CONFIG_FILE" ]; then
    SAVE_PATH=$(grep -o '"savePath": "[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)
    MODEL_TAG=$(grep -o '"modelTag": "[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)
fi

# ---------------------------------------------------------------
# Banner
# ---------------------------------------------------------------
show_banner() {
    clear
    cat << "EOF"
  ___         .__  __ __         __
 /   |  ______|__|/  |__     ____/  |______
/    | \_  __ \  \   __\   /  _ \   __\__  \
/     Y  \  | \/  ||  |    (  <_> )  |  / __ \_
\____|__  /__|  |__||__|     \____/|__| (____  /
        \/                                  \/

   ARIJIT APP MAKING IN JAVA
   Local vibe-coding, zero cloud, zero rate limits.
   Unlike other LLMs -> NO RATE LIMITS. Ask as much as you want.

EOF
    echo "   Model in use : $MODEL_TAG"
    echo "   Apps saved to: $SAVE_PATH"
    echo ""
    echo "   ============================================="
    echo "   COMMANDS"
    echo "   A                 - start a new app-building session"
    echo "   setpath <path>    - change where apps get saved"
    echo "   exit              - quit this tool"
    echo "   ============================================="
    echo ""
}

# ---------------------------------------------------------------
# Ollama API call
# ---------------------------------------------------------------
invoke_model() {
    local prompt="$1"
    local response=$(curl -s -X POST http://localhost:11434/api/generate \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL_TAG\",
            \"prompt\": \"$prompt\",
            \"stream\": false
        }" | grep -o '"response":"[^"]*' | cut -d'"' -f4 | sed 's/\\n/\n/g')
    echo "$response"
}

# ---------------------------------------------------------------
# Extract Java code from response
# ---------------------------------------------------------------
extract_java_code() {
    local text="$1"
    if echo "$text" | grep -q '```java'; then
        echo "$text" | sed -n '/```java/,/```/p' | sed '1d;$d'
    else
        echo "$text"
    fi
}

# ---------------------------------------------------------------
# Extract class name from code
# ---------------------------------------------------------------
extract_class_name() {
    local code="$1"
    echo "$code" | grep -o 'public class [A-Za-z_][A-Za-z0-9_]*' | head -1 | awk '{print $3}'
}

# ---------------------------------------------------------------
# Save Java file (UTF-8 without BOM)
# ---------------------------------------------------------------
save_java_file() {
    local code="$1"
    local class_name="$2"
    local file_path="$SAVE_PATH/${class_name}.java"
    
    mkdir -p "$SAVE_PATH"
    echo -n "$code" > "$file_path"
    echo "$file_path"
}

# ---------------------------------------------------------------
# Compile and run
# ---------------------------------------------------------------
compile_and_run() {
    local class_name="$1"
    
    echo ""
    echo ">> Compiling $class_name.java ..."
    cd "$SAVE_PATH"
    
    if ! javac "${class_name}.java" 2>&1; then
        local compile_error=$(javac "${class_name}.java" 2>&1)
        echo ">> Compile failed:"
        echo "$compile_error" | head -20
        echo "compile_error"
        return 1
    fi
    
    echo ">> Compiled OK. Running $class_name ..."
    echo ""
    
    # Run with timeout to catch startup crashes
    if timeout 5 java "$class_name" 2>&1; then
        echo ""
        echo ">> App exited normally."
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo ">> App is running (a window may be open). Close it when done."
            return 0
        else
            local runtime_error=$(timeout 5 java "$class_name" 2>&1)
            echo ">> App crashed at runtime:"
            echo "$runtime_error" | head -20
            echo "runtime_error"
            return 1
        fi
    fi
}

# ---------------------------------------------------------------
# Main session loop
# ---------------------------------------------------------------
start_session() {
    echo ""
    echo "Ask anything, I will build it."
    echo "(Type 'Finish' at any point to end this session.)"
    echo ""
    
    local last_code=""
    local last_class_name=""
    
    while true; do
        echo -n "You: "
        read user_input
        
        if [ "$user_input" = "Finish" ]; then
            echo ""
            echo "Session ended."
            return
        fi
        
        if [ "$user_input" = "run" ]; then
            if [ -z "$last_class_name" ]; then
                echo "No code generated yet in this session."
                continue
            fi
            
            local error=$(compile_and_run "$last_class_name")
            
            if [ "$error" = "compile_error" ] || [ "$error" = "runtime_error" ]; then
                echo ""
                echo -n "Issue captured. Describe the fix or press Enter to auto-fix: "
                read issue_desc
                
                local fix_prompt="This code has an error:

\`\`\`java
$last_code
\`\`\`

Error:
$error

Fix it."
                
                echo ""
                echo ">> Sending fix request to model..."
                local response=$(invoke_model "$fix_prompt")
                last_code=$(extract_java_code "$response")
                last_class_name=$(extract_class_name "$last_code")
                
                if [ -n "$last_class_name" ]; then
                    local path=$(save_java_file "$last_code" "$last_class_name")
                    echo ">> Fixed code saved to: $path"
                fi
            fi
            
            echo ""
            echo "Any issues? tell me, I will code accordingly. (or type 'run' again, or 'Finish')"
            continue
        fi
        
        echo ""
        echo ">> Building..."
        local response=$(invoke_model "$user_input")
        last_code=$(extract_java_code "$response")
        last_class_name=$(extract_class_name "$last_code")
        
        if [ -z "$last_class_name" ]; then
            echo ">> Could not detect a public class name in the response. Raw output:"
            echo "$response"
            continue
        fi
        
        local path=$(save_java_file "$last_code" "$last_class_name")
        echo ""
        echo ">> Saved to: $path"
        echo ""
        echo "Any issues? tell me, I will code accordingly."
        echo "(or type 'run' to compile and run it, or 'Finish' to end)"
    done
}

# ---------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------
show_banner

while true; do
    echo -n "> "
    read cmd
    
    if [ "$cmd" = "A" ]; then
        start_session
        show_banner
    elif [ "$cmd" = "exit" ]; then
        echo "Goodbye."
        break
    elif [[ "$cmd" == setpath* ]]; then
        new_path="${cmd#setpath }"
        if [ -n "$new_path" ]; then
            SAVE_PATH="$new_path"
            mkdir -p "$SAVE_PATH"
            mkdir -p "$INSTALL_DIR/.config"
            cat > "$INSTALL_DIR/.config/config.json" <<EOF
{
  "savePath": "$SAVE_PATH",
  "modelTag": "$MODEL_TAG"
}
EOF
            echo "Save path updated to: $SAVE_PATH"
            show_banner
        fi
    else
        echo "Unknown command. Type 'A' to start, 'setpath <path>' to change save location, or 'exit'."
    fi
done
