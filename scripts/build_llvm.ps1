# AI-Optima: LLVM/MLIR Build Script
# This script clones LLVM 18.1.8, configures with MLIR enabled, and builds.
# Expected time: 1-2 hours on a modern machine.
# Expected disk usage: ~20-30 GB

param(
    [string]$LLVMRoot = "D:\mega project\llvm-project",
    [string]$BuildDir = "D:\mega project\llvm-build",
    [string]$InstallDir = "D:\mega project\llvm-install",
    [int]$Jobs = 4,           # Limit parallelism for 16GB RAM
    [int]$LinkJobs = 2,       # Limit parallel linker jobs (linker is memory-heavy)
    [string]$BuildType = "Release"
)

$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  AI-Optima: LLVM/MLIR Builder" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  LLVM Source : $LLVMRoot"
Write-Host "  Build Dir   : $BuildDir"
Write-Host "  Install Dir : $InstallDir"
Write-Host "  Build Type  : $BuildType"
Write-Host "  Parallel    : $Jobs compile, $LinkJobs link"
Write-Host ""

# Ensure tools are in PATH
$toolDirs = @("D:\mega project\tools\ninja", "D:\mega project\tools\cmake\bin")
foreach ($dir in $toolDirs) {
    if (Test-Path $dir) {
        $env:PATH = "$dir;$env:PATH"
    }
}

# ─── Prerequisite checks ───────────────────────────────────────────────────────
function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

$missing = @()
if (!(Test-Command "cmake"))  { $missing += "CMake" }
if (!(Test-Command "ninja"))  { $missing += "Ninja" }
if (!(Test-Command "git"))    { $missing += "Git" }

if ($missing.Count -gt 0) {
    Write-Host "[ERROR] Missing required tools: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "Run .\scripts\setup_deps.ps1 as Administrator first." -ForegroundColor Yellow
    exit 1
}

# ─── Step 1: Clone LLVM ────────────────────────────────────────────────────────
if (Test-Path $LLVMRoot) {
    Write-Host "[1/3] LLVM source already exists at $LLVMRoot. Skipping clone." -ForegroundColor Yellow
} else {
    Write-Host "[1/3] Cloning LLVM 18.1.8 (shallow clone)..." -ForegroundColor Green
    git clone --depth 1 --branch llvmorg-18.1.8 `
        https://github.com/llvm/llvm-project.git $LLVMRoot
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Git clone failed." -ForegroundColor Red
        exit 1
    }
}

# ─── Step 2: Configure with CMake ──────────────────────────────────────────────
Write-Host ""
Write-Host "[2/3] Configuring LLVM build with MLIR enabled..." -ForegroundColor Green

$portableClang = "D:\mega project\tools\llvm-mingw\bin\clang.exe"
$useClang = Test-Path $portableClang

if ($useClang) {
    Write-Host "  Using Portable Clang Toolchain: $portableClang" -ForegroundColor Cyan
    $env:PATH = "D:\mega project\tools\llvm-mingw\bin;D:\mega project\tools\cmake\bin;D:\mega project\tools\ninja;" + $env:PATH
} else {
    # Try to find Visual Studio vcvarsall.bat for MSVC compiler
    $vcvarsall = $null
    $vsLocations = @(
        "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    )

    foreach ($loc in $vsLocations) {
        if (Test-Path $loc) {
            $vcvarsall = $loc
            Write-Host "  Found Visual Studio: $loc" -ForegroundColor Gray
            break
        }
    }
}

# Create build directory
New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

# Run CMake configuration
$cmakeArgs = @(
    "-S", "$LLVMRoot\llvm",
    "-B", "$BuildDir",
    "-G", "Ninja",
    "-DLLVM_ENABLE_PROJECTS=mlir",
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DLLVM_TARGETS_TO_BUILD=X86",
    "-DLLVM_ENABLE_ASSERTIONS=ON",
    "-DLLVM_PARALLEL_LINK_JOBS=$LinkJobs",
    "-DLLVM_ENABLE_ZLIB=OFF",
    "-DLLVM_ENABLE_ZSTD=OFF",
    "-DLLVM_ENABLE_TERMINFO=OFF",
    "-DCMAKE_INSTALL_PREFIX=$InstallDir",
    "-DMLIR_ENABLE_BINDINGS_PYTHON=OFF"
)

if ($useClang) {
    $cmakeArgs += "-DCMAKE_C_COMPILER=clang.exe"
    $cmakeArgs += "-DCMAKE_CXX_COMPILER=clang++.exe"
    & cmake @cmakeArgs
} elseif ($vcvarsall) {
    cmd /c "call `"$vcvarsall`" x64 && cmake $($cmakeArgs -join ' ')"
} else {
    & cmake @cmakeArgs
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] CMake configuration failed." -ForegroundColor Red
    exit 1
}

# ─── Step 3: Build & Install ───────────────────────────────────────────────────
Write-Host ""
Write-Host "[3/3] Building LLVM/MLIR (this will take 1-2 hours)..." -ForegroundColor Green
Write-Host "  Using $Jobs parallel compile jobs." -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date

if ($useClang) {
    & ninja -C $BuildDir -j $Jobs
} elseif ($vcvarsall) {
    cmd /c "call `"$vcvarsall`" x64 && ninja -C `"$BuildDir`" -j $Jobs"
} else {
    & ninja -C $BuildDir -j $Jobs
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Build failed." -ForegroundColor Red
    Write-Host "  Try reducing parallelism: .\scripts\build_llvm.ps1 -Jobs 2" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Installing to $InstallDir..." -ForegroundColor Green

if ($useClang) {
    & ninja -C $BuildDir install
} elseif ($vcvarsall) {
    cmd /c "call `"$vcvarsall`" x64 && ninja -C `"$BuildDir`" install"
} else {
    & ninja -C $BuildDir install
}

$elapsed = (Get-Date) - $startTime

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  LLVM/MLIR Build Complete!" -ForegroundColor Green
Write-Host "  Time elapsed: $($elapsed.ToString('hh\:mm\:ss'))" -ForegroundColor Gray
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Set these environment variables:" -ForegroundColor Yellow
Write-Host "  `$env:LLVM_DIR  = `"$InstallDir`""
Write-Host "  `$env:MLIR_DIR  = `"$InstallDir\lib\cmake\mlir`""
Write-Host "  `$env:PATH     += `";$InstallDir\bin`""
Write-Host ""
Write-Host "Then run: .\scripts\build_project.ps1" -ForegroundColor Yellow
