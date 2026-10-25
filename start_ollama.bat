@echo off
:: 切換編碼為 UTF-8 以支援中文
chcp 65001 >nul
title Ollama 啟動與模型清單

:: ==========================================
:: 設定模式：0 = 前景執行（預設），1 = 背景執行
:: ==========================================
set RUN_IN_BACKGROUND=0

echo ==================================================
echo   正在檢查 Ollama 服務狀態... (模式: %RUN_IN_BACKGROUND%)
echo ==================================================

:: 透過 curl 檢查服務是否已在運作
curl -s http://localhost:11434/ | findstr /C:"Ollama is running" >nul
if %errorlevel% equ 0 (
    echo [提示] 偵測到 Ollama 伺服器正在運行中！
    goto PRINT_LIST
)

:: --- 未在運行：依模式啟動服務 ---
if "%RUN_IN_BACKGROUND%"=="1" (
    echo [模式] 以背景啟動 ollama serve...
    start "Ollama Server" /min cmd /c "ollama serve"
    timeout /t 3 /nobreak >nul
    goto PRINT_LIST
) else (
    echo [模式] 前景模式：先在背景查詢模型清單...
    start "Ollama Server" /min cmd /c "ollama serve"
    timeout /t 3 /nobreak >nul

    echo.
    echo ==================================================
    echo   目前本地可用的 LLM 模型清單：
    echo ==================================================
    echo.
    ollama list

    echo.
    echo ==================================================
    echo   切換至當前視窗持續監控（按 Ctrl+C 可停止）
    echo ==================================================
    taskkill /f /im ollama.exe >nul 2>&1
    timeout /t 1 /nobreak >nul

    :: 直接執行前景服務
    ollama serve
    exit /b
)

:PRINT_LIST
echo.
echo ==================================================
echo   目前本地可用的 LLM 模型清單：
echo ==================================================
echo.
ollama list

echo.
echo ==================================================
echo   完成。按任意鍵關閉此視窗...
echo ==================================================
pause >nul