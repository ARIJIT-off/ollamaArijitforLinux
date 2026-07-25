# =============================================================
# install.ps1
# One-command installer for Arijitappmakinginjava
#
# Usage (from any PowerShell window):
#   irm https://raw.githubusercontent.com/ARIJIT-off/ollamaArijit/main/install.ps1 | iex
# =============================================================

$ErrorActionPreference = "Stop"
$InstallDir  = "C:\javallm"
$ModelTag    = "arijitp203/Arijitjavacodes3b"
$RepoBase    = "https://raw.githubusercontent.com/ARIJIT-off/ollamaArijit/main"

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host " Arijitappmakinginjava - Installer" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------
# Step 1: Check / install Ollama
# ---------------------------------------------------------------
Write-Host "[1/6] Checking for Ollama..." -ForegroundColor Yellow
$ollamaInstalled = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaInstalled) {
    Write-Host "      Ollama not found. Installing via winget..." -ForegroundColor Gray
    winget install -e --id Ollama.Ollama --accept-source-agreements --accept-package-agreements
    Write-Host "      Ollama installed. You may need to restart this terminal after setup completes." -ForegroundColor Green
} else {
    Write-Host "      Ollama already installed." -ForegroundColor Green
}

# ---------------------------------------------------------------
# Step 2: Check / install JDK
# ---------------------------------------------------------------
Write-Host ""
Write-Host "[2/6] Checking for a JDK (javac)..." -ForegroundColor Yellow
$javacInstalled = Get-Command javac -ErrorAction SilentlyContinue
if (-not $javacInstalled) {
    Write-Host "      javac not found. Installing OpenJDK 21 via winget..." -ForegroundColor Gray
    winget install -e --id Microsoft.OpenJDK.21 --accept-source-agreements --accept-package-agreements
    Write-Host "      JDK installed. You may need to restart this terminal for PATH changes to apply." -ForegroundColor Green
} else {
    Write-Host "      JDK already installed." -ForegroundColor Green
}

# ---------------------------------------------------------------
# Step 3: Pull the fine-tuned model
# ---------------------------------------------------------------
Write-Host ""
Write-Host "[3/6] Pulling model '$ModelTag' (this is a large download, please wait)..." -ForegroundColor Yellow
try {
    ollama pull $ModelTag
    Write-Host "      Model pulled successfully." -ForegroundColor Green
} catch {
    Write-Host "      Could not pull the model automatically. If Ollama was just installed," -ForegroundColor Red
    Write-Host "      close this window, open a new PowerShell, and run:" -ForegroundColor Red
    Write-Host "      ollama pull $ModelTag" -ForegroundColor White
}

# ---------------------------------------------------------------
# Step 4: Download the CLI script files
# ---------------------------------------------------------------
Write-Host ""
Write-Host "[4/6] Downloading Arijitappmakinginjava files to $InstallDir ..." -ForegroundColor Yellow
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

Invoke-WebRequest -Uri "$RepoBase/Arijitappmakinginjava.ps1" -OutFile "$InstallDir\Arijitappmakinginjava.ps1"
Invoke-WebRequest -Uri "$RepoBase/Arijitappmakinginjava.cmd" -OutFile "$InstallDir\Arijitappmakinginjava.cmd"
Write-Host "      Files downloaded." -ForegroundColor Green

# ---------------------------------------------------------------
# Step 5: Point the script at the correct model name, unblock, set policy
# ---------------------------------------------------------------
Write-Host ""
Write-Host "[5/6] Configuring script and permissions..." -ForegroundColor Yellow

(Get-Content "$InstallDir\Arijitappmakinginjava.ps1") `
    -replace '\$ModelName\s*=.*', "`$ModelName   = `"$ModelTag`"" |
    Set-Content "$InstallDir\Arijitappmakinginjava.ps1"

Unblock-File -Path "$InstallDir\Arijitappmakinginjava.ps1"
Unblock-File -Path "$InstallDir\Arijitappmakinginjava.cmd"

try {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
} catch {
    Write-Host "      Could not set execution policy automatically. If launching the tool fails," -ForegroundColor Red
    Write-Host "      run this once yourself:" -ForegroundColor Red
    Write-Host "      Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned" -ForegroundColor White
}

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$InstallDir", "User")
    Write-Host "      Added $InstallDir to your PATH." -ForegroundColor Green
} else {
    Write-Host "      $InstallDir already in PATH." -ForegroundColor Green
}

# ---------------------------------------------------------------
# Step 6: Ask for save location
# ---------------------------------------------------------------
Write-Host ""
Write-Host "[6/6] Choose where generated Java apps should be saved." -ForegroundColor Yellow
$savePath = Read-Host "      Enter a folder path (or press Enter to use Desktop\java codes)"
if ([string]::IsNullOrWhiteSpace($savePath)) {
    $savePath = Join-Path $env:USERPROFILE "Desktop\java codes"
}
if (-not (Test-Path $savePath)) {
    New-Item -ItemType Directory -Path $savePath -Force | Out-Null
}
$configDir = "$env:USERPROFILE\.arijitjavacodes"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}
@{ SavePath = $savePath } | ConvertTo-Json | Set-Content "$configDir\config.json"
Write-Host "      Save path set to: $savePath" -ForegroundColor Green

# ---------------------------------------------------------------
# Done
# ---------------------------------------------------------------
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host " Install complete!" -ForegroundColor Green
Write-Host ""
Write-Host " Close and reopen PowerShell, then run:" -ForegroundColor White
Write-Host "   Arijitappmakinginjava" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
