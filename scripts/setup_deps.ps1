#Requires -RunAsAdministrator
# AI-Optima: Dependency Installation Script
# Run this script as Administrator in PowerShell

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  AI-Optima Dependency Installer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check for Chocolatey
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Chocolatey not found. Installing..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host ""
Write-Host "[1/4] Installing CMake..." -ForegroundColor Green
choco install cmake --installargs "ADD_CMAKE_TO_PATH=System" -y --no-progress
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] CMake installation failed. Please install manually." -ForegroundColor Red
}

Write-Host ""
Write-Host "[2/4] Installing Ninja..." -ForegroundColor Green
choco install ninja -y --no-progress
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Ninja installation failed. Please install manually." -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/4] Installing Visual Studio 2022 Build Tools with C++ workload..." -ForegroundColor Green
Write-Host "       This may take 10-20 minutes." -ForegroundColor Yellow
winget install Microsoft.VisualStudio.2022.BuildTools `
    --override "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive --wait" `
    --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] VS Build Tools installation may have failed. Check manually." -ForegroundColor Red
}

Write-Host ""
Write-Host "[4/4] Installing Python packages for benchmarking..." -ForegroundColor Green
pip install matplotlib numpy --quiet

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: Run .\scripts\build_llvm.ps1 to build LLVM/MLIR" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: Close and reopen your terminal to refresh PATH." -ForegroundColor Red
