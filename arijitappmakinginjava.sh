# =============================================================
# Arijitappmakinginjava.ps1
# Local Java Swing app generator powered by your fine-tuned
# Qwen2.5-Coder-3B model running through Ollama.
#
# SETUP (one-time):
#   1. Save this file as: Arijitappmakinginjava.ps1
#   2. Put it somewhere on your PATH, e.g. C:\javallm\
#   3. Create a matching Arijitappmakinginjava.cmd in the same
#      folder (see instructions below) so you can just type
#      "Arijitappmakinginjava" from any PowerShell window.
# =============================================================

$ModelName   = "Arijitjavacodes3b"
$ConfigDir   = "$env:USERPROFILE\.arijitjavacodes"
$ConfigFile  = "$ConfigDir\config.json"
$DefaultPath = "C:\Users\aleri\OneDrive - INSTITUTE OF ENGINEERING & MANAGEMENT\Desktop\java codes(OOP)"

# ---------------------------------------------------------------
# Config load/save (remembers your save path between sessions)
# ---------------------------------------------------------------
function Load-Config {
    if (-not (Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }
    if (Test-Path $ConfigFile) {
        try {
            $cfg = Get-Content $ConfigFile -Raw | ConvertFrom-Json
            return $cfg.SavePath
        } catch {
            return $DefaultPath
        }
    }
    return $DefaultPath
}

function Save-Config($path) {
    $cfg = @{ SavePath = $path } | ConvertTo-Json
    Set-Content -Path $ConfigFile -Value $cfg
}

$SavePath = Load-Config

# ---------------------------------------------------------------
# Banner
# ---------------------------------------------------------------
function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ___         .__  __ __         __         " -ForegroundColor Cyan
    Write-Host " /   |  ______|__|/  |__     ____/  |______  " -ForegroundColor Cyan
    Write-Host "/    | \\_  __ \\  \\   __\\   /  _ \\   __\\__  \\ " -ForegroundColor Cyan
    Write-Host "/     Y  \\  | \\/  ||  |    (  <_> )  |  / __ \\_" -ForegroundColor Cyan
    Write-Host "\\____|__  /__|  |__||__|     \\____/|__| (____  /" -ForegroundColor Cyan
    Write-Host "        \\/                                  \\/  " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   ARIJIT APP MAKING IN JAVA" -ForegroundColor Yellow
    Write-Host "   Local vibe-coding, zero cloud, zero rate limits." -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Unlike other LLMs -> NO RATE LIMITS. Ask as much as you want." -ForegroundColor Green
    Write-Host ""
    Write-Host "   Model in use : $ModelName" -ForegroundColor White
    Write-Host "   Apps saved to: $SavePath" -ForegroundColor White
    Write-Host ""
    Write-Host "   ---------------------------------------------" -ForegroundColor DarkGray
    Write-Host "   COMMANDS" -ForegroundColor Yellow
    Write-Host "   A                 - start a new app-building session"
    Write-Host "   setpath <path>    - change where apps get saved"
    Write-Host "   exit              - quit this tool"
    Write-Host "   ---------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# ---------------------------------------------------------------
# Ollama call — sends a prompt, returns the raw text response
# ---------------------------------------------------------------
function Invoke-Model($prompt) {
    # Call Ollama's local API directly instead of shelling out to "ollama run".
    # This returns clean JSON text with zero terminal rendering artifacts -
    # no ANSI codes, no carriage-return overwrites, no duplicated lines.
    $body = @{
        model  = $ModelName
        prompt = $prompt
        stream = $false
    } | ConvertTo-Json -Compress

    try {
        $result = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json"
        return $result.response
    } catch {
        Write-Host "Error contacting Ollama API: $_" -ForegroundColor Red
        Write-Host "Make sure Ollama is running (it usually runs automatically in the background)." -ForegroundColor Yellow
        return ""
    }
}

# ---------------------------------------------------------------
# Extract the ```java ... ``` code block from a model response
# ---------------------------------------------------------------
function Extract-JavaCode($text) {
    if ($text -match '(?s)```java\s*(.*?)```') {
        return $Matches[1].Trim()
    }
    if ($text -match '(?s)```\s*(.*?)```') {
        return $Matches[1].Trim()
    }
    # fallback: no fence pair found - strip any stray ``` lines and return the rest
    $lines = $text -split "`n" | Where-Object { $_.Trim() -ne '```java' -and $_.Trim() -ne '```' }
    return ($lines -join "`n").Trim()
}

# ---------------------------------------------------------------
# Extract the public class name so we know what to name the file
# ---------------------------------------------------------------
function Extract-ClassName($code) {
    if ($code -match 'public\s+class\s+(\w+)') {
        return $Matches[1]
    }
    return $null
}

# ---------------------------------------------------------------
# Save code to disk at $SavePath, return the full file path
# ---------------------------------------------------------------
function Save-JavaFile($code, $className) {
    if (-not (Test-Path $SavePath)) {
        New-Item -ItemType Directory -Path $SavePath -Force | Out-Null
    }
    $filePath = Join-Path $SavePath "$className.java"
    # Use UTF8 WITHOUT BOM - a leading BOM causes "illegal character" errors in javac.
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($filePath, $code, $utf8NoBom)
    return $filePath
}

# ---------------------------------------------------------------
# Compile + run the saved file, show output directly.
# Also captures runtime crashes (uncaught exceptions), not just
# compile errors, and returns them the same way so they can be
# fed back into the fix loop.
# ---------------------------------------------------------------
function Compile-And-Run($className) {
    Push-Location $SavePath
    Write-Host ""
    Write-Host ">> Compiling $className.java ..." -ForegroundColor Yellow
    $compileOutput = & javac "$className.java" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host ">> Compile failed:" -ForegroundColor Red
        Write-Host $compileOutput -ForegroundColor Red
        Pop-Location
        return @{ Type = "compile"; Message = ($compileOutput -join "`n") }
    }
    Write-Host ">> Compiled OK. Running $className ..." -ForegroundColor Green
    Write-Host ""

    $errFile = Join-Path $env:TEMP "$className-stderr-$PID.txt"
    $outFile = Join-Path $env:TEMP "$className-stdout-$PID.txt"
    if (Test-Path $errFile) { Remove-Item $errFile -Force }
    if (Test-Path $outFile) { Remove-Item $outFile -Force }

    $proc = Start-Process -FilePath "java" -ArgumentList $className `
        -WorkingDirectory $SavePath -RedirectStandardError $errFile `
        -RedirectStandardOutput $outFile -PassThru -NoNewWindow

    # Give it a few seconds - long enough for a startup crash to happen and
    # get written to stderr, short enough that a normal GUI app (which just
    # sits open waiting for the user) doesn't block the tool.
    $exited = $proc.WaitForExit(4000)

    if ($exited) {
        $stderrText = if (Test-Path $errFile) { Get-Content $errFile -Raw } else { "" }
        if ($proc.ExitCode -ne 0 -or ($stderrText -match "Exception")) {
            Write-Host ">> App crashed at runtime:" -ForegroundColor Red
            Write-Host $stderrText -ForegroundColor Red
            Pop-Location
            return @{ Type = "runtime"; Message = $stderrText }
        }
        Write-Host ">> App exited normally." -ForegroundColor Green
    } else {
        Write-Host ">> App is running (a window may be open). Close it manually when you're done." -ForegroundColor Green
    }

    Pop-Location
    return $null
}

# ---------------------------------------------------------------
# One app-building session: build -> ask about issues -> fix loop
# ---------------------------------------------------------------
function Start-Session {
    Write-Host ""
    Write-Host "Ask anything, I will build it." -ForegroundColor Cyan
    Write-Host "(Type 'Finish' at any point to end this session.)" -ForegroundColor DarkGray
    Write-Host ""

    $lastCode = $null
    $lastClassName = $null

    while ($true) {
        Write-Host "You: " -ForegroundColor Yellow -NoNewline
        $userInput = Read-Host

        if ($userInput -eq "Finish") {
            Write-Host ""
            Write-Host "Session ended." -ForegroundColor Gray
            return
        }

        if ($userInput -eq "run") {
            if (-not $lastClassName) {
                Write-Host "No code generated yet in this session." -ForegroundColor Red
                continue
            }
            $errResult = Compile-And-Run $lastClassName
            if ($errResult) {
                $errKind = if ($errResult.Type -eq "runtime") { "Runtime crash" } else { "Compile error" }
                Write-Host ""
                Write-Host "$errKind captured. Describe the issue or just hit enter to send this error as-is:" -ForegroundColor Yellow
                $issueNote = Read-Host
                $issueText = if ([string]::IsNullOrWhiteSpace($issueNote)) { $errResult.Message } else { "$issueNote`n`n$($errResult.Type) output:`n$($errResult.Message)" }
                $fixPrompt = "This code has an error:`n`n``````java`n$lastCode`n``````n`nError message:`n$issueText`n`nFix it."
                Write-Host ""
                Write-Host ">> Sending fix request to model..." -ForegroundColor Yellow
                $response = Invoke-Model $fixPrompt
                $lastCode = Extract-JavaCode $response
                $lastClassName = Extract-ClassName $lastCode
                if ($lastClassName) {
                    $path = Save-JavaFile $lastCode $lastClassName
                    Write-Host ">> Fixed code saved to: $path" -ForegroundColor Green
                }
            }
            Write-Host ""
            Write-Host "Any issues? tell me, I will code accordingly. (or type 'run' again, or 'Finish')" -ForegroundColor Cyan
            continue
        }

        # First message in session, or a follow-up "build/fix" request
        if (-not $lastCode) {
            Write-Host ""
            Write-Host ">> Building..." -ForegroundColor Yellow
            $response = Invoke-Model $userInput
        } else {
            $fixPrompt = "This code has an issue:`n`n``````java`n$lastCode`n``````n`nIssue described by user:`n$userInput`n`nFix it."
            Write-Host ""
            Write-Host ">> Coding a fix..." -ForegroundColor Yellow
            $response = Invoke-Model $fixPrompt
        }

        $lastCode = Extract-JavaCode $response
        $lastClassName = Extract-ClassName $lastCode

        if (-not $lastClassName) {
            Write-Host ">> Could not detect a public class name in the response. Raw output:" -ForegroundColor Red
            Write-Host $response
            continue
        }

        $path = Save-JavaFile $lastCode $lastClassName
        Write-Host ""
        Write-Host ">> Saved to: $path" -ForegroundColor Green
        Write-Host ""
        Write-Host "Any issues? tell me, I will code accordingly." -ForegroundColor Cyan
        Write-Host "(or type 'run' to compile and run it, or 'Finish' to end)" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------
Show-Banner

while ($true) {
    Write-Host "> " -NoNewline -ForegroundColor White
    $cmd = Read-Host

    if ($cmd -eq "A") {
        Start-Session
        Show-Banner
    }
    elseif ($cmd -eq "exit") {
        Write-Host "Goodbye." -ForegroundColor Gray
        break
    }
    elseif ($cmd -like "setpath *") {
        $newPath = $cmd.Substring(8).Trim()
        if ($newPath.Length -gt 0) {
            $SavePath = $newPath
            Save-Config $SavePath
            Write-Host "Save path updated to: $SavePath" -ForegroundColor Green
            Start-Sleep -Seconds 1
            Show-Banner
        }
    }
    else {
        Write-Host "Unknown command. Type 'A' to start, 'setpath <path>' to change save location, or 'exit'." -ForegroundColor Red
    }
}
