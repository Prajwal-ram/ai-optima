# AI-Optima: Project Build Script
# Run this after building LLVM/MLIR with build_llvm.ps1

param(
    [string]$LLVMInstall = "D:\mega project\llvm-install",
    [string]$BuildDir = "D:\mega project\ai-optima\build",
    [string]$SourceDir = "D:\mega project\ai-optima",
    [int]$Jobs = 4,
    [string]$BuildType = "Release"
)

$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  AI-Optima Project Builder" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Ensure tools are in PATH
$toolDirs = @("D:\mega project\tools\ninja", "D:\mega project\tools\cmake\bin")
foreach ($dir in $toolDirs) {
    if (Test-Path $dir) {
        $env:PATH = "$dir;$env:PATH"
    }
}

# ─── Verify LLVM installation ───────────────────────────────────────────────
$mlirConfig = Join-Path $LLVMInstall "lib\cmake\mlir\MLIRConfig.cmake"
if (!(Test-Path $mlirConfig)) {
    Write-Host "[ERROR] MLIR not found at: $mlirConfig" -ForegroundColor Red
    Write-Host "  Run .\scripts\build_llvm.ps1 first." -ForegroundColor Yellow
    exit 1
}
Write-Host "Found MLIR: $mlirConfig" -ForegroundColor Green

$portableClang = "D:\mega project\tools\llvm-mingw\bin\clang.exe"
$useClang = Test-Path $portableClang

if ($useClang) {
    Write-Host "Using Portable Clang: $portableClang" -ForegroundColor Cyan
    $env:PATH = "D:\mega project\tools\llvm-mingw\bin;D:\mega project\tools\cmake\bin;D:\mega project\tools\ninja;" + $env:PATH
} else {
    $vcvarsall = $null
    $vsLocations = @(
        "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    )

    foreach ($loc in $vsLocations) {
        if (Test-Path $loc) {
            $vcvarsall = $loc
            break
        }
    }
}

# ─── Configure ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[1/2] Configuring AI-Optima..." -ForegroundColor Green

New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

$cmakeArgs = @(
    "-S", $SourceDir,
    "-B", $BuildDir,
    "-G", "Ninja",
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DMLIR_DIR=$LLVMInstall\lib\cmake\mlir",
    "-DLLVM_DIR=$LLVMInstall\lib\cmake\llvm",
    "-DLLVM_EXTERNAL_LIT=$LLVMInstall\bin\llvm-lit.py"
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

# ─── Build ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[2/2] Building AI-Optima..." -ForegroundColor Green

if ($useClang) {
    & ninja -C $BuildDir -j $Jobs
} elseif ($vcvarsall) {
    cmd /c "call `"$vcvarsall`" x64 && ninja -C `"$BuildDir`" -j $Jobs"
} else {
    & ninja -C $BuildDir -j $Jobs
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Build failed." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Binary: $BuildDir\bin\dl-opt-tool.exe" -ForegroundColor Yellow
Write-Host ""
Write-Host "Quick test:" -ForegroundColor Yellow
Write-Host "  $BuildDir\bin\dl-opt-tool.exe test\fusion_test.mlir --dlopt-fusion"
Write-Host "  $BuildDir\bin\dl-opt-tool.exe test\full_pipeline.mlir --dlopt-pipeline"
Write-Host ""
