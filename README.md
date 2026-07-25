# Arijitappmakinginjava — User Manual

**Version:** 2.0  
**Last Updated:** July 26, 2026  
**Platforms:** Windows, Linux, macOS, Raspberry Pi 4+

---

## 🎯 Quick Start

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/ARIJIT-off/ollamaArijit/main/install.ps1 | iex
```

### Linux & macOS (Bash)
```bash
curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main/install.sh | bash
```

Both installers handle everything: Ollama, JDK, model download, CLI setup. Just restart your terminal after and type `arijitappmakinginjava` to start.

---

## 📋 What Gets Installed

The one-command installer sets up:
- **Ollama** — Local inference engine for the fine-tuned model
- **OpenJDK 21** (or compatible) — Java compiler and runtime
- **arijitp203/Arijitjavacodes3b** — Qwen2.5-Coder-3B fine-tuned on 29 Java Swing examples
- **CLI Tool** — Interactive prompt-driven code generator

**Total download:** ~2GB (model is quantized to Q4_K_M)  
**Total install time:** 2–5 minutes (depending on internet speed)

---

## 🚀 Using the Tool

Once installed, start a new session:

```bash
arijitappmakinginjava
```

You'll see a welcome banner and menu:

```
==========================================
  Arijitappmakinginjava - Java App Gen
==========================================
Model: arijitp203/Arijitjavacodes3b
Save Directory: ~/ArijitJavaApps (or C:\Users\...\ArijitJavaApps on Windows)

What would you like to do?
[A] Ask Claude to build an app
[C] Change save directory
[Finish] Exit
```

### Interactive Commands

#### **[A] — Generate an App**
```
Enter choice: A
Describe your Java app: create a calculator app
```

The tool:
1. Sends your prompt to the local Ollama model
2. Generates a complete, single-file `.java` file
3. Saves it to your save directory
4. Asks if you want to compile and run it

```
[✓] Code saved to: ~/ArijitJavaApps/Calculator.java
Compile and run? (y/n): y
[✓] Compiled successfully
[*] Running app (close window to continue)...
```

The app launches in a Swing window. Close it to return to the menu.

#### **[C] — Change Save Directory**
```
Enter choice: C
Enter new save directory (full path): /home/username/MyCustomFolder
[✓] Save directory changed to: /home/username/MyCustomFolder
```

All future apps save there instead.

#### **[Finish] — Exit**
```
Enter choice: Finish
Goodbye!
```

---

## 📱 What It Can Generate

The model was fine-tuned on:
- **Utilities:** Calculator, clock, timer, unit converter
- **Games:** Tic-tac-toe, rock-paper-scissors
- **GUI Apps:** Todo list, settings panels, dashboard

**Strong outputs:** Single-layout apps, simple games, calculators with state management  
**Weaker outputs:** Complex games (Tetris, Chess) without explicit detailed prompts

**Tip:** Be specific in your prompt. Instead of "create a game," try "create a tic-tac-toe game with a 3x3 grid, human vs computer, reset button, and status display."

---

## 💻 System Requirements

| Platform | CPU | RAM | Disk | JDK | Notes |
|----------|-----|-----|------|-----|-------|
| **Windows 10/11** | Any modern CPU | 8GB+ | 3GB | Installed auto | PowerShell 5.1+ |
| **Linux (Ubuntu/Debian)** | x86-64 or ARM64 | 8GB+ | 3GB | Installed auto | Bash shell |
| **macOS** | Intel/Apple Silicon | 8GB+ | 3GB | Installed auto | Monterey+ |
| **Raspberry Pi 4** | ARM Cortex-A72 | 8GB | 3GB | Installed auto | Headless or HDMI |

---

## 🐧 Raspberry Pi 4 Setup & Usage

**Status:** ✅ **Fully supported** (with performance caveats)

### Installation
```bash
curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main/install.sh | bash
```

### Real-World Performance

Tested on **Raspberry Pi 4 (8GB, Ubuntu 22.04)**:

| Task | Windows PC | Raspberry Pi 4 |
|------|-----------|-----------------|
| Model inference | 2–5 seconds | 15–30 seconds |
| Compilation | < 1 second | 1–2 seconds |
| App launch | Instant | 2–3 seconds |

**Verdict:** Works great for code generation, acceptable for local app testing.

### Use Cases

**✅ Good fit:**
- Headless code generation backend (generate `.java` files, download to main PC)
- Pi + HDMI monitor attached (generate and test locally)
- Remote code-gen service (SSH access from other machines)

**❌ Not ideal:**
- Real-time interactive development (slow feedback loop)
- Complex app testing (model struggles with Tetris, Chess anyway)

### Example Session on Pi

```bash
arijit@raspberrypi:~$ arijitappmakinginjava
==========================================
  Arijitappmakinginjava - Java App Gen
==========================================

Enter choice: A
Describe your Java app: create a digital clock showing current time
[*] Generating code with arijitp203/Arijitjavacodes3b...
[✓] Code saved to: /home/arijit/ArijitJavaApps/DigitalClock.java
Compile and run? (y/n): y
[✓] Compiled successfully
[*] Running app (close window to continue)...
```

If you have HDMI connected, the clock window opens. If headless, the app runs in the background. Either way, the `.java` file is saved and ready.

---

## 🔧 Troubleshooting

### "Ollama is not running"
**Windows:**
```powershell
ollama serve
```

**Linux/macOS:**
```bash
ollama serve
```

This starts the Ollama daemon on `localhost:11434`. Keep it running in a separate terminal.

### "Model not found: arijitp203/Arijitjavacodes3b"
The installer should pull it automatically, but if it fails:

```bash
ollama pull arijitp203/Arijitjavacodes3b
```

Wait for the full 1.9GB download to complete.

### "javac: command not found"
JDK isn't installed or not in PATH. Reinstall:

**Windows:**
```powershell
irm https://raw.githubusercontent.com/ARIJIT-off/ollamaArijit/main/install.ps1 | iex
```

**Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main/install.sh | bash
```

Then restart your terminal.

### "No valid Java code generated"
The model couldn't understand your prompt. Try being more specific:

❌ **Vague:**
```
create a game
```

✅ **Specific:**
```
create a tic-tac-toe game with a 3x3 grid, human vs computer using random moves, a reset button, and a status label showing whose turn it is
```

### Generated code doesn't compile
The model sometimes makes mistakes (missing imports, typos). The CLI will show the compilation error. You can:

1. Edit the `.java` file manually and recompile
2. Ask the tool to regenerate with a corrected prompt
3. Report the error [here](https://github.com/ARIJIT-off/ollamaArijit/issues)

---

## 📂 File Organization

Apps are saved by default to:

**Windows:**
```
C:\Users\<YourUsername>\ArijitJavaApps\
```

**Linux/macOS:**
```
~/ArijitJavaApps/
```

**Raspberry Pi:**
```
/home/<username>/ArijitJavaApps/
```

Each generated app gets its own `.java` file with the class name. Compiled `.class` files and any errors appear in the same folder.

---

## 🎓 Model Details

**Base Model:** Qwen2.5-Coder-3B-Instruct  
**Fine-tuning Method:** LoRA (r=32, α=64)  
**Training Data:** 29 hand-curated Java Swing examples  
**Quantization:** Q4_K_M (GGUF)  
**Model Size:** ~2GB  
**Context Window:** 2048 tokens  
**Temperature:** 0.3 (deterministic outputs)

**Training was done on Google Colab (free T4 GPU).** The adapter is merged and quantized for Ollama deployment.

---

## 🌐 Offline Use

Once the model is pulled locally, everything runs **100% offline** — no internet connection needed after installation.

```bash
ollama serve  # Keep this running
# In another terminal:
arijitappmakinginjava  # Works completely offline
```

---

## 🔄 Updating the Tool

To update to the latest version:

**Windows:**
```powershell
irm https://raw.githubusercontent.com/ARIJIT-off/ollamaArijit/main/install.ps1 | iex
```

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijitforLinux/main/install.sh | bash
```

This re-downloads the CLI script and ensures Ollama/JDK are up to date. No need to re-download the 1.9GB model if it's already installed.

---

## 📊 Limitations & Honest Assessment

**What works well:**
- ✅ Single-file utilities (calculator, clock, todo list)
- ✅ Simple turn-based games (tic-tac-toe, rock-paper-scissors)
- ✅ Standard Swing layouts (BorderLayout, GridLayout)
- ✅ Error detection and re-prompting (if code fails to compile)

**What struggles:**
- ❌ Complex games (Tetris, Snake, Chess) — requires very detailed prompts
- ❌ Multi-file projects — only generates single `.java` files
- ❌ External library integration (JDBC, networking) — trained only on `javax.swing.*` and `java.awt.*`
- ❌ Performance-critical code — no optimization

**Generalization note:** With only 29 training examples, the model is likely **memorizing** those specific apps rather than learning generalizable patterns. New prompts outside the training distribution may produce lower-quality code. Scaling the dataset to 100+ examples would significantly improve this.

---

## 🚀 Next Steps / Advanced Usage

### Generating Multiple Variants
Ask for the same app with different styles:

```
create a calculator app with a dark theme and rounded buttons
```

vs.

```
create a calculator app with a light theme and rectangular buttons
```

Both will generate valid code with different aesthetics.

### Error-Driven Development
If an app crashes at runtime:

1. The CLI captures the error message
2. Re-prompt with context: `"Fix the previous code — it crashed with: [error message]"`
3. The model often corrects the mistake on the second try

### Combining Multiple Requests
You can ask for an enhanced version:

```
create a calculator app that also shows calculation history in a JTextArea below the buttons
```

The model will attempt to combine features.

---

## 📝 FAQ

**Q: Can I use this commercially?**  
A: The fine-tuned model and CLI tool are open-source (MIT license). Generated code is yours to use as you wish.

**Q: Does it work offline?**  
A: Yes, completely. After the initial install, Ollama runs locally with no internet required.

**Q: Can I modify the CLI script?**  
A: Absolutely. It's open-source on GitHub — fork, customize, submit PRs.

**Q: Why Qwen-3B instead of a larger model?**  
A: Sweet spot between quality and resource usage. Runs on Pi 4 without external GPU. Larger models would require 8GB+ GPU memory.

**Q: Can I fine-tune it further with my own examples?**  
A: Yes. The training notebook is public. Create your own dataset (JSONL format), run through Colab, export to GGUF, load into Ollama.

**Q: How is this different from ChatGPT / GitHub Copilot?**  
A: It's **local, free, and offline**. No API costs, no rate limits, no data sent to external servers. Trade-off: smaller model, more specialized (Java only).

---

## 📞 Support & Feedback

**Issues/Bugs:** [GitHub Issues](https://github.com/ARIJIT-off/ollamaArijit/issues)  
**Feature Requests:** [GitHub Discussions](https://github.com/ARIJIT-off/ollamaArijit/discussions)  
**Model on Ollama:** `ollama pull arijitp203/Arijitjavacodes3b`

---

## 🎉 Credits

**Fine-tuning & deployment:** Arijit Pal (3rd-year CSE-Data Science, UEM Kolkata)  
**Base model:** Qwen2.5-Coder by Alibaba DAMO Academy  
**Inference engine:** Ollama by Jared Kaplan  
**Training framework:** Unsloth by Daniel Han  

---

**Happy coding!** 🚀✨

Generated apps are single-file, compilable, and ready to customize. Start with the tool's outputs and iterate from there.
