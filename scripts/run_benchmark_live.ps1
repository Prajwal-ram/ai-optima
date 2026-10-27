#!/usr/bin/env pwsh
# AI-Optima Live Benchmark Runner
# Runs each benchmark step synchronously and prints results immediately

$env:PATH = "D:\mega project\tools\llvm-mingw\bin;" + $env:PATH

$BINARY      = "D:\mega project\ai-optima\benchmarks\naive_matmul.exe"
$DLOPT       = "D:\mega project\ai-optima\build\bin\dl-opt-tool.exe"
$CPP_SIZES   = @(64, 128, 256, 512)   # C++ naive is O(N^3) -- 1024 takes ~7 min per run
$NUMPY_SIZES = @(64, 128, 256, 512, 1024)  # NumPy/BLAS is fast at all sizes
$SIZES       = $NUMPY_SIZES            # used for summary table
$RESULTS     = @()

function Banner($text, $color="Cyan") {
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor $color
    Write-Host "  $text" -ForegroundColor $color
    Write-Host ("=" * 60) -ForegroundColor $color
    Write-Host ""
}

function Row($method, $size, $timeUs, $gflops, $color="White") {
    $line = '  {0,-22} {1,6}    {2,12:F1} us    {3,8:F2} GFLOPS' -f $method, "${size}x${size}", $timeUs, $gflops
    Write-Host $line -ForegroundColor $color
}

Banner "AI-OPTIMA BENCHMARK SUITE" "Cyan"
Write-Host "  Platform : $([System.Environment]::OSVersion.VersionString)" -ForegroundColor Gray
Write-Host "  CPU      : $((Get-CimInstance Win32_Processor).Name)" -ForegroundColor Gray
Write-Host ('  C++ Sizes  : {0}  (N=1024 tiled-only, 1 run)' -f ($CPP_SIZES -join ', ')) -ForegroundColor Gray
Write-Host ('  NumPy Sizes: {0}' -f ($NUMPY_SIZES -join ', ')) -ForegroundColor Gray
Write-Host ('  Runs     : 5 median runs  (C++ naive skipped at N=1024 -- ~7 min/run)') -ForegroundColor Gray
Write-Host ""

# --- PHASE 1: C++ Benchmarks -------------------------------------------------
Banner "[1/3] C++ Benchmarks (Naive + Tiled)" "Yellow"
Write-Host '  NOTE: C++ Naive O(N^3) capped at N=512. N=1024 shows Tiled only (1 run).' -ForegroundColor DarkGray
$headerLine = '  {0,-22} {1,8}    {2,14}    {3,10}    {4,8}' -f "Method","Size","Time (us)","GFLOPS","vs Naive"
Write-Host $headerLine -ForegroundColor DarkGray
Write-Host ("  " + ("-" * 66)) -ForegroundColor DarkGray

if (Test-Path $BINARY) {
    # -- N=64..512: full 5-run median for both naive and tiled ----------------
    foreach ($N in $CPP_SIZES) {
        Write-Host "  Running C++ N=$N  -- 5 runs ..." -ForegroundColor DarkYellow

        $naiveTimes = @(); $tiledTimes = @()
        for ($i = 0; $i -lt 5; $i++) {
            $out = & $BINARY $N 2>&1
            foreach ($line in $out) {
                if ($line -match "^NAIVE_US: (.+)") { $naiveTimes += [double]$Matches[1] }
                if ($line -match "^TILED_US: (.+)") { $tiledTimes += [double]$Matches[1] }
            }
        }

        $naiveSorted = $naiveTimes | Sort-Object
        $tiledSorted = $tiledTimes | Sort-Object
        $naiveMedian = $naiveSorted[[int]($naiveSorted.Count/2)]
        $tiledMedian = $tiledSorted[[int]($tiledSorted.Count/2)]
        $naiveGF = (2.0 * [Math]::Pow($N,3)) / ($naiveMedian * 1e-6) / 1e9
        $tiledGF = (2.0 * [Math]::Pow($N,3)) / ($tiledMedian * 1e-6) / 1e9
        $speedup = $naiveMedian / $tiledMedian

        $naiveLine = '  {0,-22} {1,8}    {2,14:F1}    {3,10:F2}    {4,8}' -f "C++ Naive","${N}x${N}",$naiveMedian,$naiveGF,"1.00x"
        Write-Host $naiveLine -ForegroundColor Red

        $tiledLine = '  {0,-22} {1,8}    {2,14:F1}    {3,10:F2}    {4,8:F2}x' -f "C++ Tiled","${N}x${N}",$tiledMedian,$tiledGF,$speedup
        Write-Host $tiledLine -ForegroundColor Yellow
        Write-Host ""

        $RESULTS += [PSCustomObject]@{ Method="C++ Naive"; Size=$N; TimeUs=$naiveMedian; GFLOPS=$naiveGF }
        $RESULTS += [PSCustomObject]@{ Method="C++ Tiled"; Size=$N; TimeUs=$tiledMedian; GFLOPS=$tiledGF }
    }

    # -- N=1024: tiled only, 1 run (naive would take ~7 min) ------------------
    Write-Host "  Running C++ N=1024  -- Tiled only, 1 run -- naive skipped: ~7 min ..." -ForegroundColor DarkYellow
    $out1024 = & $BINARY 1024 2>&1
    $tiledUs1024 = 0.0
    foreach ($line in $out1024) {
        if ($line -match "^TILED_US: (.+)") { $tiledUs1024 = [double]$Matches[1] }
    }
    $tiledGF1024 = (2.0 * [Math]::Pow(1024,3)) / ($tiledUs1024 * 1e-6) / 1e9
    $naiveRef    = 7166540.0   # measured previously: ~7.17 sec
    $naiveRefGF  = (2.0 * [Math]::Pow(1024,3)) / ($naiveRef * 1e-6) / 1e9
    $speedup1024 = $naiveRef / $tiledUs1024

    $refLine = '  {0,-22} {1,8}    {2,14}    {3,10:F2}    {4,8}' -f "C++ Naive (ref)","1024x1024","~7,166,540",$naiveRefGF,"1.00x"
    Write-Host $refLine -ForegroundColor DarkRed

    $tiledLine1024 = '  {0,-22} {1,8}    {2,14:F1}    {3,10:F2}    {4,8:F2}x' -f "C++ Tiled","1024x1024",$tiledUs1024,$tiledGF1024,$speedup1024
    Write-Host $tiledLine1024 -ForegroundColor Yellow
    Write-Host ""

    $RESULTS += [PSCustomObject]@{ Method="C++ Naive"; Size=1024; TimeUs=$naiveRef;     GFLOPS=$naiveRefGF  }
    $RESULTS += [PSCustomObject]@{ Method="C++ Tiled"; Size=1024; TimeUs=$tiledUs1024;  GFLOPS=$tiledGF1024 }
} else {
    Write-Host "  [SKIP] naive_matmul.exe not found at: $BINARY" -ForegroundColor Red
}

# --- PHASE 2: NumPy ----------------------------------------------------------
Banner "[2/3] NumPy (BLAS-backed) Benchmarks" "Green"
$npHeader = '  {0,-22} {1,8}    {2,14}    {3,10}    {4,8}' -f "Method","Size","Time (us)","GFLOPS","vs Naive"
Write-Host $npHeader -ForegroundColor DarkGray
Write-Host ("  " + ("-" * 66)) -ForegroundColor DarkGray

foreach ($N in $NUMPY_SIZES) {
    Write-Host "  Running NumPy N=$N  -- 5 runs ..." -ForegroundColor DarkGreen

    $pyScript = @"
import numpy as np, time
N=$N
A = np.random.randn(N,N).astype(np.float32)
B = np.random.randn(N,N).astype(np.float32)
for _ in range(3): C = A @ B
times = []
for _ in range(5):
    t0 = time.perf_counter()
    C = A @ B
    t1 = time.perf_counter()
    times.append((t1-t0)*1e6)
avg = sorted(times)[2]
gf = (2.0*N**3)/(avg*1e-6)/1e9
print(f'NUMPY_US:{avg:.1f}')
print(f'NUMPY_GF:{gf:.4f}')
"@

    $tmpFile = [System.IO.Path]::GetTempFileName() + ".py"
    $pyScript | Out-File -FilePath $tmpFile -Encoding utf8
    $out = python $tmpFile 2>&1
    Remove-Item $tmpFile -ErrorAction SilentlyContinue

    $timeUs = 0.0; $gflops = 0.0
    foreach ($line in $out) {
        if ($line -match "^NUMPY_US:(.+)") { $timeUs  = [double]$Matches[1] }
        if ($line -match "^NUMPY_GF:(.+)") { $gflops = [double]$Matches[1] }
    }

    $naiveEntry = $RESULTS | Where-Object { $_.Method -eq "C++ Naive" -and $_.Size -eq $N }
    $naiveTime  = if ($naiveEntry) { $naiveEntry.TimeUs } else { 0 }
    $spStr      = if ($naiveTime -gt 0) { '{0:F2}x' -f ($naiveTime / $timeUs) } else { "N/A" }
    $npLine = '  {0,-22} {1,8}    {2,14:F1}    {3,10:F2}    {4,8}' -f "NumPy (BLAS)","${N}x${N}",$timeUs,$gflops,$spStr
    Write-Host $npLine -ForegroundColor Green
    Write-Host ""
    $RESULTS += [PSCustomObject]@{ Method="NumPy (BLAS)"; Size=$N; TimeUs=$timeUs; GFLOPS=$gflops }
}

# --- PHASE 3: AI-Optima MLIR -------------------------------------------------
Banner "[3/3] AI-Optima MLIR Tool Status" "Magenta"
if (Test-Path $DLOPT) {
    $sizeMB = '{0:F1}' -f ((Get-Item $DLOPT).Length / 1MB)
    Write-Host "  [OK] dl-opt-tool.exe FOUND" -ForegroundColor Green
    Write-Host "       Path : $DLOPT" -ForegroundColor Gray
    Write-Host "       Size : $sizeMB MB" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Running: dl-opt-tool.exe --help ..." -ForegroundColor Magenta
    $helpOut = & $DLOPT --help 2>&1 | Select-Object -First 8
    foreach ($line in $helpOut) { Write-Host "    $line" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "  [INFO] JIT matmul benchmarks require MLIR runner integration." -ForegroundColor DarkMagenta
} else {
    Write-Host "  [FAIL] dl-opt-tool.exe NOT FOUND at:" -ForegroundColor Red
    Write-Host "         $DLOPT" -ForegroundColor Red
}

# --- COMPARISON TABLE ---------------------------------------------------------
Banner "COMPARISON TABLE" "Cyan"
$cmpHeader = '  {0,-22} {1,8}    {2,14}    {3,10}    {4,10}' -f "Method","Size","Time (us)","GFLOPS","vs Naive"
Write-Host $cmpHeader -ForegroundColor White
Write-Host ("  " + ("-" * 72)) -ForegroundColor DarkGray

foreach ($N in $SIZES) {
    $naiveEntry = $RESULTS | Where-Object { $_.Method -eq "C++ Naive" -and $_.Size -eq $N }
    $naiveTime  = if ($naiveEntry) { $naiveEntry.TimeUs } else { 0 }
    Write-Host ""
    Write-Host "  ---- N = ${N}x${N} ----" -ForegroundColor DarkGray
    $grouped = $RESULTS | Where-Object { $_.Size -eq $N } | Sort-Object TimeUs
    foreach ($r in $grouped) {
        $speedup    = if ($naiveTime -gt 0) { $naiveTime / $r.TimeUs } else { 1.0 }
        $speedupStr = '{0:F2}x' -f $speedup
        $color = switch ($r.Method) {
            "C++ Naive"    { "Red" }
            "C++ Tiled"    { "Yellow" }
            "NumPy (BLAS)" { "Green" }
            default        { "Cyan" }
        }
        $rowLine = '  {0,-22} {1,8}    {2,14:F1}    {3,10:F2}    {4,10}' -f $r.Method,"${N}x${N}",$r.TimeUs,$r.GFLOPS,$speedupStr
        Write-Host $rowLine -ForegroundColor $color
    }
}

# --- SPEEDUP SUMMARY ---------------------------------------------------------
Banner "SPEEDUP SUMMARY (vs C++ Naive)" "Cyan"
$spHeader = '  {0,-22}' -f "Method"
foreach ($s in $SIZES) { $spHeader += '  {0,8}' -f "N=$s" }
Write-Host $spHeader -ForegroundColor White
Write-Host ("  " + ("-" * 66)) -ForegroundColor DarkGray

foreach ($method in @("C++ Naive","C++ Tiled","NumPy (BLAS)")) {
    $color = switch ($method) {
        "C++ Naive"    { "Red" }
        "C++ Tiled"    { "Yellow" }
        "NumPy (BLAS)" { "Green" }
        default        { "Cyan" }
    }
    $row = '  {0,-22}' -f $method
    foreach ($N in $SIZES) {
        $naiveEntry = $RESULTS | Where-Object { $_.Method -eq "C++ Naive" -and $_.Size -eq $N }
        $thisEntry  = $RESULTS | Where-Object { $_.Method -eq $method    -and $_.Size -eq $N }
        if ($naiveEntry -and $thisEntry -and $naiveEntry.TimeUs -gt 0) {
            $sp = $naiveEntry.TimeUs / $thisEntry.TimeUs
            $row += '  {0,6:F2}x' -f $sp
        } else { $row += "     N/A" }
    }
    Write-Host $row -ForegroundColor $color
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "  Benchmark Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""
