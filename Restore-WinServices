@echo off
:: Verifica se já está em modo administrador
>nul 2>&1 fltmc || (
    :: Se não for admin, relança silenciosamente com elevação
    PowerShell.exe -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs -WindowStyle Hidden"
    exit /b
)

:: =============================================
:: A PARTIR DAQUI O CÓDIGO EXECUTA COMO ADMIN!
:: =============================================

PowerShell.exe -Command "Import-Csv 'backup_servicos.txt' | ForEach-Object { sc.exe config $_.Name start= $_.StartMode }"
