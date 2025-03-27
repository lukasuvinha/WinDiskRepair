@echo off
:: Auto-elevação
>nul 2>&1 fltmc || (
    PowerShell.exe -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs -WindowStyle Hidden"
    exit /b
)

:: =============================================
:: A PARTIR DAQUI O CÓDIGO EXECUTA COMO ADMIN!
:: =============================================

:: Define diretório do script como local de trabalho
cd /d "%~dp0"

:: Backup dos serviços
if not exist "backup_servicos.txt" (
    echo [BACKUP] Criando backup em "%~dp0backup_servicos.txt"...
    PowerShell.exe -Command ^
        "Get-CimInstance -ClassName Win32_Service | ^
        Where-Object { $_.StartMode -ne 'Disabled' } | ^
        Select-Object Name, StartMode | ^
        Export-Csv -Path '%~dp0backup_servicos.txt' -NoTypeInformation"
)

:: Desativação de serviços corrigida
echo [AÇÃO] Desativando serviços de terceiros...
PowerShell.exe -Command ^
    "$excluded = 'C:\\Windows', 'Program Files', 'Program Files (x86)'; ^
    Get-CimInstance Win32_Service | ^
    Where-Object { ^
        $_.PathName -and ^
        -not ($excluded -match [regex]::Escape($_.PathName)) -and ^
        $_.StartMode -ne 'Disabled' } | ^
    ForEach-Object { ^
        $name = $_.Name; ^
        sc.exe config `"$name`" start= disabled ^| Out-Null; ^
        if ($LASTEXITCODE -eq 0) { Write-Host \"$name desativado\" } else { Write-Host \"Falha em $name\" } }"

:: Verificações do sistema (ordem correta)
echo [INFO] Verificando integridade do sistema...
dism /online /cleanup-image /CheckHealth
dism /online /cleanup-image /RestoreHealth
sfc /scannow

echo [AVISO] O CHKDSK será agendado para o próximo boot!
echo Y | chkdsk /f /r /x

echo.
echo [COMPLETO] Ações concluídas! Reinicie o computador.
pause
