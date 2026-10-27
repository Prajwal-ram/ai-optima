param(
    [int[]]$Sizes = @(16, 32, 64, 128),
    [int]$Runs = 15,
    [int]$TileSize = 16,
    [switch]$Dense
)

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$tool = Join-Path $projectRoot "build\bin\dl-opt-tool.exe"
$llvmBin = "D:\mega project\llvm-install\bin"
if (!(Test-Path $tool)) {
    throw "Compiler not found. Build the project first with .\scripts\build_project.ps1"
}
if (Test-Path $llvmBin) {
    $env:PATH = "$llvmBin;$env:PATH"
}
if ($Runs -lt 3 -or $TileSize -lt 1) {
    throw "Use at least 3 timed runs and a positive tile size."
}

$workDir = Join-Path $projectRoot "build\benchmarks"
$resultsDir = Join-Path $projectRoot "benchmarks\results"
$mode = if ($Dense) { "dense" } else { "matmul" }
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
$results = @()
try {
    $cpu = (Get-CimInstance Win32_Processor -ErrorAction Stop |
        Select-Object -First 1 -ExpandProperty Name)
} catch {
    $cpu = if ($env:PROCESSOR_IDENTIFIER) { $env:PROCESSOR_IDENTIFIER } else { "Unknown CPU" }
}

foreach ($n in $Sizes) {
    if ($n -lt 1) { throw "Matrix sizes must be positive." }
    $irPath = Join-Path $workDir "${mode}_$n.mlir"
    if ($Dense) {
        $source = @"
func.func @benchmark_dense(%lhs: tensor<${n}x${n}xf32>, %rhs: tensor<${n}x${n}xf32>, %bias: tensor<${n}xf32>) -> tensor<${n}x${n}xf32> {
  %product = dlopt.matmul %lhs, %rhs : tensor<${n}x${n}xf32>, tensor<${n}x${n}xf32> -> tensor<${n}x${n}xf32>
  %biased = dlopt.bias_add %product, %bias : tensor<${n}x${n}xf32>, tensor<${n}xf32> -> tensor<${n}x${n}xf32>
  %result = dlopt.relu %biased : tensor<${n}x${n}xf32>
  return %result : tensor<${n}x${n}xf32>
}
"@
        $benchmarkFunction = "benchmark_dense"
    } else {
        $source = @"
func.func @benchmark_matmul(%lhs: tensor<${n}x${n}xf32>, %rhs: tensor<${n}x${n}xf32>) -> tensor<${n}x${n}xf32> {
  %result = dlopt.matmul %lhs, %rhs : tensor<${n}x${n}xf32>, tensor<${n}x${n}xf32> -> tensor<${n}x${n}xf32>
  return %result : tensor<${n}x${n}xf32>
}
"@
        $benchmarkFunction = "benchmark_matmul"
    }
    [System.IO.File]::WriteAllText(
        $irPath, $source, [System.Text.UTF8Encoding]::new($false))

    Write-Host "Benchmarking $mode ${n}x${n} (tile=$TileSize, runs=$Runs)..." -ForegroundColor Cyan
    $previousPreference = $ErrorActionPreference
    $nativePreference = Get-Variable -Name PSNativeCommandUseErrorActionPreference `
        -ErrorAction SilentlyContinue
    try {
        $ErrorActionPreference = "Continue"
        if ($null -ne $nativePreference) {
            $PSNativeCommandUseErrorActionPreference = $false
        }
        $output = & $tool $irPath --dlopt-pipeline --run `
            "--entry-point=$benchmarkFunction" "--tile-size=$TileSize" `
            "--iterations=$Runs" 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
        if ($null -ne $nativePreference) {
            $PSNativeCommandUseErrorActionPreference = $nativePreference.Value
        }
    }
    if ($exitCode -ne 0) {
        Write-Host $output
        throw "AI-Optima benchmark failed for matrix size $n (exit $exitCode)."
    }

    $fields = @{}
    foreach ($line in ($output -split "`r?`n")) {
        if ($line -match "^([A-Z_]+):\s*(.+)$") {
            $fields[$Matches[1]] = $Matches[2].Trim()
        }
    }
    if ($fields.RESULT -ne "PASS") {
        throw "Numerical comparison failed at matrix size $n."
    }
    $row = [PSCustomObject]@{
        Mode = $mode
        Size = $n
        TileSize = $TileSize
        Runs = $Runs
        MedianJitUs = [double]::Parse($fields.MEDIAN_JIT_US,
            [Globalization.CultureInfo]::InvariantCulture)
        MedianCppReferenceUs = [double]::Parse($fields.MEDIAN_CPP_REFERENCE_US,
            [Globalization.CultureInfo]::InvariantCulture)
        SpeedupVsCppReference = [double]::Parse(
            $fields.SPEEDUP_VS_CPP_REFERENCE.TrimEnd('x'),
            [Globalization.CultureInfo]::InvariantCulture)
        JitGflops = [double]::Parse($fields.JIT_GFLOPS,
            [Globalization.CultureInfo]::InvariantCulture)
        MaxAbsoluteError = [double]::Parse($fields.MAX_ABS_ERROR,
            [Globalization.CultureInfo]::InvariantCulture)
        Cpu = $cpu
        Os = [System.Environment]::OSVersion.VersionString
        Pipeline = "fusion, lowering, tiling, bufferization, LLVM dialect; LLVM JIT O3"
    }
    $results += $row
    Write-Host ("  PASS | JIT {0:N1} us | C++ reference {1:N1} us | {2:N2}x | max error {3:G3}" -f `
        $row.MedianJitUs, $row.MedianCppReferenceUs, `
        $row.SpeedupVsCppReference, $row.MaxAbsoluteError) -ForegroundColor Green
}

$csvPath = Join-Path $resultsDir "aioptima_${mode}_benchmark.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "`nResults saved to $csvPath" -ForegroundColor Cyan
Write-Host "These are local exploratory measurements; compare results only on the same machine and build." -ForegroundColor Yellow
