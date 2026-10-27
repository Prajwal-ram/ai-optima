@echo off
title AI-Optima: Visual Studio 2022 C++ Installer

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo =====================================================================
    echo  Requesting Administrator privileges...
    echo  Please click "Yes" on the Windows pop-up prompt.
    echo =====================================================================
    powershell -Command "Start-Process cmd -ArgumentList '/c `"%~f0`"' -Verb RunAs"
    exit /b
)

:: Running with Administrator privileges
echo =====================================================================
echo  AI-Optima: Installing Visual Studio 2022 C++ Build Tools & SDK
echo =====================================================================
echo.
echo Launching Visual Studio Installer...
echo The Visual Studio Installer window will now open on your screen.
echo.

"D:\mega project\vs_BuildTools.exe" --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended

echo.
echo =====================================================================
echo  Installer launched / completed!
echo =====================================================================
pause
