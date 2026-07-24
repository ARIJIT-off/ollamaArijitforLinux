# Arijitappmakinginjava - Linux/macOS Edition

Generate Java Swing applications locally with zero cloud, zero rate limits, and zero API costs.

## One-Command Install

```bash
curl -fsSL https://raw.githubusercontent.com/ARIJIT-off/ollamaArijit-linux/main/install.sh | bash
```

This automatically:
- Installs Ollama (if missing)
- Installs OpenJDK 21 (if missing)
- Pulls your fine-tuned model from Ollama's registry
- Downloads and sets up the CLI tool
- Adds it to your PATH

## First Run

After installation, restart your terminal or run:
```bash
source ~/.bashrc  # or source ~/.zshrc if you use zsh
```

Then simply:
```bash
arijitappmakinginjava
```

You'll see a welcome banner with available commands.

## Usage

Inside the tool:

| Command | What it does |
|---|---|
| `A` | Start a new app-building session |
| `setpath <path>` | Change where apps get saved |
| `exit` | Quit the tool |

### Example: Build a Calculator

```
> A
Ask anything, I will build it.
(Type 'Finish' at any point to end this session.)

You: create a calculator app
>> Building...
>> Saved to: /home/user/java_apps/Calculator.java

Any issues? tell me, I will code accordingly.
(or type 'run' to compile and run it, or 'Finish' to end)

You: run
>> Compiling Calculator.java ...
>> Compiled OK. Running Calculator ...
[Calculator app window opens]
```

If the app has a bug, just describe it:
```
You: the buttons are too small
>> Sending fix request to model...
>> Fixed code saved to: /home/user/java_apps/Calculator.java
```

Type `Finish` to end the session.

## System Requirements

- **Linux (Ubuntu/Fedora/Debian) or macOS**
- **Ollama** (installed automatically by the installer)
- **OpenJDK 21** (installed automatically by the installer)
- **~2GB free disk space** for the model

## Supported Platforms

- Ubuntu 20.04+
- Debian 11+
- Fedora 36+
- macOS 11+
- Any Linux distro with `apt-get`, `dnf`, or `brew`

## Troubleshooting

**Command not found after install:**
Restart your terminal, or run:
```bash
source ~/.bashrc
```

**Model download fails:**
The model is ~2GB. If your connection is slow or unstable, just retry:
```bash
ollama pull arijitp203/Arijitjavacodes3b
```

**App compilation fails:**
The tool will show the compiler error. Describe it in plain English:
```
You: the error says "cannot find symbol"
```
The model will attempt to fix it.

## File Locations

- **Config**: `~/.arijitappmakinginjava/.config/config.json`
- **CLI script**: `~/.arijitappmakinginjava/arijitappmakinginjava.sh`
- **Generated apps**: `~/java_apps/` (customizable via `setpath`)

## For Windows Users

If you're on Windows, use the Windows-specific installer instead:
```powershell
irm https://raw.githubusercontent.com/ARIJIT-off/ollamaArijit/main/install.ps1 | iex
```

Then use `Arijitappmakinginjava` (PowerShell command) instead of `arijitappmakinginjava` (bash).

## What This Tool Can Do

Best results for:
- Utilities (Calculator, Clock, Timer, Converter, Password Generator)
- Simple Games (Tic Tac Toe, Rock Paper Scissors, Dice Roller)
- Data Tools (Todo List, Note Editor, Character Counter)

For more complex apps (Tetris, Chess, custom simulations), describe them in detail so the model knows exactly what you want.

## Limitations

The underlying model is 3B parameters, fine-tuned on ~30 examples. It's great for utilities and simple apps, but may need iteration on complex logic. Always test generated code before running it in production.

## Questions or Issues?

Found a bug or have a feature request? Open an issue on GitHub:
https://github.com/ARIJIT-off/ollamaArijit-linux

Enjoy! 🚀
