# Reproducible exhibition demo for the AI-Optima compiler.
$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$tool = Join-Path $projectRoot "build\bin\dl-opt-tool.exe"
$llvmBin = "D:\mega project\llvm-install\bin"
if (Test-Path $llvmBin) {
    $env:PATH = "$llvmBin;$env:PATH"
}

if (!(Test-Path $tool)) {
    throw "Compiler not found. Build the project first with .\scripts\build_project.ps1"
}

function Invoke-DemoCheck([string]$label, [string[]]$arguments) {
    Write-Host "`n[$label]" -ForegroundColor Cyan
    $previousErrorActionPreference = $ErrorActionPreference
    $nativePreference = Get-Variable -Name PSNativeCommandUseErrorActionPreference `
        -ErrorAction SilentlyContinue
    try {
        # JIT progress is written to stderr. Capture it as text; use the native
        # process exit code below to distinguish real failures from progress.
        $ErrorActionPreference = "Continue"
        if ($null -ne $nativePreference) {
            $PSNativeCommandUseErrorActionPreference = $false
        }
        $output = & $tool @arguments 2>&1 | Out-String
        $commandExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
        if ($null -ne $nativePreference) {
            $PSNativeCommandUseErrorActionPreference = $nativePreference.Value
        }
    }
    if ($commandExitCode -ne 0) {
        Write-Host $output
        throw "Demo step '$label' failed with exit code $commandExitCode"
    }
    return $output
}

$fusion = Invoke-DemoCheck "Fusion" @(
    (Join-Path $projectRoot "test\fusion_test.mlir"), "--dlopt-fusion")
if ($fusion -notmatch "dlopt\.fused_matmul_bias_relu" -or
    $fusion -notmatch "func\.func @no_fusion_multi_use" -or
    $fusion -notmatch "dlopt\.matmul") {
    throw "Fusion output did not show both the fused and multi-use-preserved cases."
}
Write-Host "PASS: eligible chain fused; shared intermediate chain stayed unfused." -ForegroundColor Green
($fusion -split "`r?`n" | Where-Object { $_ -match "fused_matmul_bias_relu|no_fusion_multi_use" } |
    Select-Object -First 3) | ForEach-Object { Write-Host $_ }

$tiling = Invoke-DemoCheck "Tiling with non-multiple dimensions" @(
    (Join-Path $projectRoot "test\numeric_smoke.mlir"),
    "--dlopt-lower-to-linalg", "--dlopt-tiling")
if ($tiling -notmatch "scf\.for" -or $tiling -notmatch "linalg\.generic") {
    throw "Tiling output did not contain the expected generated loops and elementwise operations."
}
Write-Host "PASS: 2x3 and 3x2 operations lowered and tiled; dimensions smaller than the default 64 tile remain valid." -ForegroundColor Green

$lowering = Invoke-DemoCheck "Full lowering" @(
    (Join-Path $projectRoot "test\full_pipeline.mlir"), "--dlopt-pipeline")
if ($lowering -notmatch "llvm\.func" -or $lowering -notmatch "llvm\.return" -or
    $lowering -match "dlopt\.") {
    throw "Full pipeline output did not reach LLVM dialect cleanly."
}
Write-Host "PASS: custom operations lowered through to LLVM dialect." -ForegroundColor Green
($lowering -split "`r?`n" | Where-Object { $_ -match "llvm\.func @dense_layer|llvm\.return" } |
    Select-Object -First 2) | ForEach-Object { Write-Host $_ }

$numeric = Invoke-DemoCheck "End-to-end numeric result" @(
    (Join-Path $projectRoot "test\numeric_smoke.mlir"),
    "--dlopt-pipeline", "--run", "--entry-point=aioptima_check", "--tile-size=4")
if ($numeric -notmatch "RESULT_F32:\s*2\.400000e\+01") {
    Write-Host $numeric
    throw "Expected the generated program to return 24."
}
Write-Host "PASS: generated program returned 24, as expected." -ForegroundColor Green

$previousErrorActionPreference = $ErrorActionPreference
$nativePreference = Get-Variable -Name PSNativeCommandUseErrorActionPreference `
    -ErrorAction SilentlyContinue
try {
    $ErrorActionPreference = "Continue"
    if ($null -ne $nativePreference) {
        $PSNativeCommandUseErrorActionPreference = $false
    }
    $badTile = & $tool (Join-Path $projectRoot "test\numeric_smoke.mlir") `
        --dlopt-pipeline --run --entry-point=aioptima_check --tile-size=0 2>&1 | Out-String
    $badTileExitCode = $LASTEXITCODE
} finally {
    $ErrorActionPreference = $previousErrorActionPreference
    if ($null -ne $nativePreference) {
        $PSNativeCommandUseErrorActionPreference = $nativePreference.Value
    }
}
if ($badTileExitCode -eq 0 -or $badTile -notmatch "Tile size must be a positive integer") {
    throw "A zero tile size should fail with a clear validation message."
}
Write-Host "PASS: invalid tile size is rejected with a clear diagnostic." -ForegroundColor Green

$runtimeMatmul = Invoke-DemoCheck "Runtime tensor matmul" @(
    (Join-Path $projectRoot "test\runtime_matmul.mlir"),
    "--dlopt-pipeline", "--run", "--entry-point=runtime_matmul",
    "--tile-size=4", "--iterations=5")
if ($runtimeMatmul -notmatch "RESULT: PASS" -or
    $runtimeMatmul -notmatch "MAX_ABS_ERROR:\s*0") {
    throw "Runtime matmul did not match the C++ reference."
}
($runtimeMatmul -split "`r?`n" | Where-Object {
    $_ -match "MATRIX_SHAPE|MAX_ABS_ERROR|MEDIAN_JIT_US|MEDIAN_CPP_REFERENCE_US"
}) | ForEach-Object { Write-Host $_ }
Write-Host "PASS: runtime matrix inputs produced the reference output." -ForegroundColor Green

$runtimeDense = Invoke-DemoCheck "Runtime matmul + bias + ReLU" @(
    (Join-Path $projectRoot "test\runtime_dense.mlir"),
    "--dlopt-pipeline", "--run", "--entry-point=runtime_dense",
    "--tile-size=4", "--iterations=5")
if ($runtimeDense -notmatch "RESULT: PASS" -or
    $runtimeDense -notmatch "MAX_ABS_ERROR:\s*0") {
    throw "Runtime dense-layer output did not match the C++ reference."
}
Write-Host "PASS: runtime matmul, bias, and ReLU matched the reference." -ForegroundColor Green

$nonSquare = Invoke-DemoCheck "Non-square partial tiles" @(
    (Join-Path $projectRoot "test\runtime_non_square.mlir"),
    "--dlopt-pipeline", "--run", "--entry-point=runtime_non_square",
    "--tile-size=16", "--iterations=5")
if ($nonSquare -notmatch "RESULT: PASS" -or
    $nonSquare -notmatch "MAX_ABS_ERROR:\s*0") {
    throw "Non-square runtime inputs did not match the C++ reference."
}
($nonSquare -split "`r?`n" | Where-Object {
    $_ -match "MATRIX_SHAPE|MAX_ABS_ERROR"
}) | ForEach-Object { Write-Host $_ }
Write-Host "PASS: partial M, N, and K tile edges matched the reference." -ForegroundColor Green

Write-Host "`nAll AI-Optima demo checks passed." -ForegroundColor Green
