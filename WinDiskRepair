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

:: Backup dos serviços atuais
if not exist "backup_servicos.txt" (
    echo [BACKUP] Criando ponto de restauração...
    PowerShell.exe -Command ^
        "Get-CimInstance -ClassName Win32_Service | ^
        Select-Object Name,StartMode | ^
        Export-Csv -Path 'backup_servicos.txt' -NoTypeInformation"
)

:: Desativação seletiva
echo [AÇÃO] Desativando serviços...
PowerShell.exe -Command ^
    "$excludedPaths = @('C:\\Windows', 'Program Files'); ^
    Get-CimInstance -ClassName Win32_Service | ^
    Where-Object { ^
        -not ($excludedPaths -match [regex]::Escape($_.PathName)) -and ^
        ($_.StartMode -ne 'Disabled') } | ^
    ForEach-Object { ^
        $service = $_; ^
        sc.exe config $service.Name start= disabled; ^
        Write-Host \"$($service.Name) => DESATIVADO\" }"

echo.
echo [AVISO] Recomendado: Crie um ponto de restauração manual!
echo [RESTAURAR] Use o script abaixo para reverter alterações:
echo.
echo PowerShell.exe -Command ^
    "Import-Csv 'backup_servicos.txt' | ForEach-Object { ^
        sc.exe config $_.Name start= $_.StartMode }"

:: Verificação de disco
sfc /scannow 
dism /online /cleanup-image /CheckHealth 
dism /online /cleanup-image /restorehealth
chkdsk /f /r /b

pause
