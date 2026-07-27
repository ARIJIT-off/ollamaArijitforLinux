#!/bin/bash
# =============================================================
# arijitappmakinginjava
# Local Java Swing app generator powered by your fine-tuned
# Qwen2.5-Coder-3B model running through Ollama. (Linux/Bash)
# =============================================================

MODEL_NAME="arijitp203/Arijitjavacodes3b"
CONFIG_DIR="$HOME/.arijitjavacodes"
CONFIG_FILE="$CONFIG_DIR/config.json"
DEFAULT_PATH="$HOME/ArijitJavaApps"

mkdir -p "$CONFIG_DIR"

# ---------------------------------------------------------------
# Load / save save-path config
# ---------------------------------------------------------------
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        grep -o '"SavePath": *"[^"]*"' "$CONFIG_FILE" | sed 's/.*: *"\(.*\)"/\1/'
    else
        echo "$DEFAULT_PATH"
    fi
}

save_config() {
    echo "{\"SavePath\": \"$1\"}" > "$CONFIG_FILE"
}

SAVE_PATH=$(load_config)
[ -z "$SAVE_PATH" ] && SAVE_PATH="$DEFAULT_PATH"
mkdir -p "$SAVE_PATH"

# ---------------------------------------------------------------
# Banner
# ---------------------------------------------------------------
show_banner() {
    clear
    echo ""
    echo "        ===      ========   ====== ======  ====== ======                      "
    echo "      //   \\   | |     ||    ||       ||    ||     ||                        "
    echo "     //=====\\  | |=====||    ||       ||    ||     ||                        " 
    echo "    //       \\ | |    \\     ||   |   ||    ||     ||                        "
    echo "   //         \\| |     \\  ======  ====   ======   🙂  JAVA SYSTEM IN LINUX "
    echo "                           ✏️ DEVELOPED BY ARIJIT PAL(CSE-DATASCIENCE, 2024 - 2028)                                        "
    echo ""
    echo "   ARIJIT APP MAKING IN JAVA"
    echo "   Local vibe-coding, zero cloud, zero rate limits."  
    echo ""
    echo "   Model in use : $MODEL_NAME"
    echo "   Apps saved to: $SAVE_PATH"
    echo ""
    echo "   ---------------------------------------------"
    echo "   COMMANDS"
    echo "   A                 - start a new app-building session"
    echo "   setpath <path>    - change where apps get saved"
    echo "   exit              - quit this tool"
    echo "   ---------------------------------------------"
    echo ""
}

# ---------------------------------------------------------------
# Call Ollama's local API, return the raw response text
# ---------------------------------------------------------------
invoke_model() {
    local prompt="$1"
    local json_prompt
    json_prompt=$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$prompt" 2>/dev/null)
    if [ -z "$json_prompt" ]; then
        # Fallback if python3 isn't available: minimal manual escaping
        json_prompt="\"$(echo "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk '{printf "%s\\n", $0}')\""
    fi

    curl -s http://localhost:11434/api/generate \
        -d "{\"model\": \"$MODEL_NAME\", \"prompt\": $json_prompt, \"stream\": false}" \
        | python3 -c 'import json,sys; print(json.load(sys.stdin).get("response",""))' 2>/dev/null
}

# ---------------------------------------------------------------
# Extract ```java ... ``` block from model response
# ---------------------------------------------------------------
extract_java_code() {
    local text="$1"
    local code
    code=$(echo "$text" | sed -n '/```java/,/```/p' | sed '1d;$d')
    if [ -z "$code" ]; then
        code=$(echo "$text" | sed -n '/```/,/```/p' | sed '1d;$d')
    fi
    if [ -z "$code" ]; then
        code=$(echo "$text" | grep -v '^```')
    fi
    echo "$code"
}

extract_class_name() {
    echo "$1" | grep -oP 'public\s+class\s+\K\w+' | head -1
}

save_java_file() {
    local code="$1"
    local class_name="$2"
    mkdir -p "$SAVE_PATH"
    local file_path="$SAVE_PATH/$class_name.java"
    printf '%s\n' "$code" > "$file_path"
    echo "$file_path"
}

# ---------------------------------------------------------------
# Compile + run, capturing compile errors and early runtime crashes
# ---------------------------------------------------------------
compile_and_run() {
    local class_name="$1"
    cd "$SAVE_PATH" || return 1
    echo ""
    echo ">> Compiling $class_name.java ..."

    local compile_output
    compile_output=$(javac "$class_name.java" 2>&1)
    if [ $? -ne 0 ]; then
        echo ">> Compile failed:"
        echo "$compile_output"
        echo "COMPILE_ERROR:$compile_output"
        return 1
    fi

    echo ">> Compiled OK. Running $class_name ..."
    echo ""

    local err_file
    err_file=$(mktemp)
    java "$class_name" 2>"$err_file" &
    local pid=$!

    sleep 4
    if kill -0 "$pid" 2>/dev/null; then
        echo ">> App is running (a window may be open). Close it manually when you're done."
        rm -f "$err_file"
        return 0
    else
        wait "$pid"
        local exit_code=$?
        local stderr_text
        stderr_text=$(cat "$err_file")
        rm -f "$err_file"
        if [ "$exit_code" -ne 0 ] || echo "$stderr_text" | grep -q "Exception"; then
            echo ">> App crashed at runtime:"
            echo "$stderr_text"
            echo "RUNTIME_ERROR:$stderr_text"
            return 1
        fi
        echo ">> App exited normally."
        return 0
    fi
}

# ---------------------------------------------------------------
# One app-building session
# ---------------------------------------------------------------
start_session() {
    echo ""
    echo "Ask anything, I will build it."
    echo "(Type 'Finish' at any point to end this session.)"
    echo ""

    local last_code=""
    local last_class=""

    while true; do
        read -p "You: " user_input

        if [ "$user_input" = "Finish" ]; then
            echo ""
            echo "Session ended."
            return
        fi

        if [ "$user_input" = "run" ]; then
            if [ -z "$last_class" ]; then
                echo "No code generated yet in this session."
                continue
            fi

            local run_result
            run_result=$(compile_and_run "$last_class")
            echo "$run_result" | grep -v "^COMPILE_ERROR:\|^RUNTIME_ERROR:"

            local err_line
            err_line=$(echo "$run_result" | grep "^COMPILE_ERROR:\|^RUNTIME_ERROR:")
            if [ -n "$err_line" ]; then
                local err_msg="${err_line#*:}"
                echo ""
                echo "Error captured. Describe the issue or just hit enter to send this error as-is:"
                read -p "> " issue_note
                local issue_text
                if [ -z "$issue_note" ]; then
                    issue_text="$err_msg"
                else
                    issue_text="$issue_note

Error output:
$err_msg"
                fi
                local fix_prompt="This code has an error:

\`\`\`java
$last_code
\`\`\`

Error message:
$issue_text

Fix it."
                echo ""
                echo ">> Sending fix request to model..."
                local response
                response=$(invoke_model "$fix_prompt")
                last_code=$(extract_java_code "$response")
                last_class=$(extract_class_name "$last_code")
                if [ -n "$last_class" ]; then
                    local path
                    path=$(save_java_file "$last_code" "$last_class")
                    echo ">> Fixed code saved to: $path"
                fi
            fi
            echo ""
            echo "Any issues? tell me, I will code accordingly. (or type 'run' again, or 'Finish')"
            continue
        fi

        local response
        if [ -z "$last_code" ]; then
            echo ""
            echo ">> Building..."
            response=$(invoke_model "$user_input")
        else
            local fix_prompt="This code has an issue:

\`\`\`java
$last_code
\`\`\`

Issue described by user:
$user_input

Fix it."
            echo ""
            echo ">> Coding a fix..."
            response=$(invoke_model "$fix_prompt")
        fi

        last_code=$(extract_java_code "$response")
        last_class=$(extract_class_name "$last_code")

        if [ -z "$last_class" ]; then
            echo ">> Could not detect a public class name in the response. Raw output:"
            echo "$response"
            continue
        fi

        local path
        path=$(save_java_file "$last_code" "$last_class")
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
    read -p "> " cmd

    case "$cmd" in
        A)
            start_session
            show_banner
            ;;
        exit)
            echo "Goodbye."
            break
            ;;
        setpath\ *)
            new_path="${cmd#setpath }"
            if [ -n "$new_path" ]; then
                SAVE_PATH="$new_path"
                mkdir -p "$SAVE_PATH"
                save_config "$SAVE_PATH"
                echo "Save path updated to: $SAVE_PATH"
                sleep 1
                show_banner
            fi
            ;;
        *)
            echo "Unknown command. Type 'A' to start, 'setpath <path>' to change save location, or 'exit'."
            ;;
    esac
done
