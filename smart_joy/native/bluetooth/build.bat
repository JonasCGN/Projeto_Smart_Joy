@echo off
setlocal enabledelayedexpansion

echo.
echo 🚀 Iniciando ambiente de compilação 64-bit...

:: Ajuste o caminho para o seu Visual Studio se necessário
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"

cd /d %~dp0

echo.
echo 🔧 Compilando bluetooth_server.cpp como DLL 64-bit...

cl /LD bluetooth_server.cpp /link ws2_32.lib Bthprops.lib User32.lib

if %errorlevel% neq 0 (
    echo.
    echo ❌ Erro na compilação da DLL. Verifique o código e tente novamente.
    pause
    exit /b %errorlevel%
)

echo.
echo ✔️ Compilação da DLL concluída com sucesso!

:: Caminho de destino - ajuste se o seu projeto Flutter tiver outra estrutura
set DEST=..\..\windows\runner\
if not exist "!DEST!" (
    echo ❌ Caminho de destino "!DEST!" não encontrado!
    pause
    exit /b 1
)

move /Y bluetooth_server.dll "!DEST!" >nul

echo.
echo 🧹 Limpando arquivos temporários...

for %%f in (bluetooth_server.obj bluetooth_server.lib bluetooth_server.exp) do (
    if exist %%f del /f /q %%f >nul 2>&1
)

echo.
echo ✅ Pronto. A DLL foi movida para "!DEST!" e os arquivos temporários foram removidos.
pause
exit /b 0
