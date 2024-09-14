@echo off
setlocal enabledelayedexpansion

REM Configura el repositorio de GitHub
set REPO_URL=https://github.com/Armando287/cro.git
set BRANCH=main

REM Directorio del script (donde está alojado el script)
set WORK_DIR=%~dp0

REM Cambia al directorio del script
cd /d "%WORK_DIR%"

REM Inicializa el repositorio si no existe
if not exist .git (
    echo Inicializando el repositorio Git...
    git init
    git remote add origin %REPO_URL%
    git fetch origin %BRANCH%
    git checkout -b %BRANCH%
)

REM Tamaño del lote
set batchSize=100
set /a counter=0

REM Obtén todos los archivos que no han sido agregados al repositorio (untracked files)
for /f "delims=" %%f in ('git ls-files --others --exclude-standard') do (
    git add "%%f"
    set /a counter+=1

    REM Cada 100 archivos, hace commit y push
    if !counter! geq %batchSize% (
        echo Haciendo commit y push de 100 archivos...
        git commit -m "Subida automática de lote de archivos"
        
        REM Intenta hacer push
        git push origin %BRANCH%
        if %ERRORLEVEL% neq 0 (
            echo Error al hacer push. Intentando hacer pull para resolver conflictos...
            git pull origin %BRANCH%
            echo Intentando hacer push nuevamente...
            git push origin %BRANCH%
        )
        set /a counter=0
    )
)

REM Realiza commit y push para los archivos restantes (si quedan menos de 100)
if !counter! gtr 0 (
    echo Haciendo commit y push para los archivos restantes...
    git commit -m "Subida automática de los archivos restantes"
    
    REM Intenta hacer push
    git push origin %BRANCH%
    if %ERRORLEVEL% neq 0 (
        echo Error al hacer push. Intentando hacer pull para resolver conflictos...
        git pull origin %BRANCH%
        echo Intentando hacer push nuevamente...
        git push origin %BRANCH%
    )
)

echo Subida completada.
pause
