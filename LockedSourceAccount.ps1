# Importar el módulo de Active Directory
Import-Module ActiveDirectory

Clear-Host

# Obtener todos los controladores de dominio
$DCs = Get-ADDomainController -Filter *

do {
    try {
        # Solicitar el nombre de usuario
        $UserName = Read-Host "Ingrese el nombre de usuario a investigar (o escriba 'salir' para terminar)"

        if ($UserName.ToLower() -eq 'salir') {
            break
        }

        $AllLockoutEvents = @()

        foreach ($DC in $DCs) {
            Write-Host "Consultando eventos en $($DC.HostName)..."

            $LockoutEvents = Invoke-Command -ComputerName $DC.HostName -ScriptBlock {
                param($UserName)
                # Obtener los eventos de bloqueo de cuenta (ID 4740) en los últimos 7 días
                $Events = Get-WinEvent -FilterHashtable @{
                    LogName = 'Security';
                    ID = 4740;
                    StartTime = (Get-Date).AddDays(-7)
                }

                # Filtrar los eventos por nombre de usuario
                $Events = $Events | Where-Object { $_.Properties[1].Value -like "*$UserName*" }

                # Extraer detalles relevantes
                $Events | ForEach-Object {
                    [PSCustomObject]@{
                        TimeCreated = $_.TimeCreated
                        AccountLockedOut = $_.Properties[1].Value  # Índice del nombre de usuario
                        CallerComputerName = $_.Properties[9].Value  # Índice del equipo de origen
                        DC = $env:COMPUTERNAME
                        Message = $_.Message
                    }
                }
            } -ArgumentList $UserName -ErrorAction SilentlyContinue

            if ($LockoutEvents) {
                $AllLockoutEvents += $LockoutEvents
            }
        }

        if ($AllLockoutEvents.Count -gt 0) {
            Write-Host "Eventos de bloqueo para el usuario '$UserName':" -ForegroundColor Green
            $AllLockoutEvents | Sort-Object TimeCreated | Format-Table -AutoSize
        } else {
            Write-Host "No se encontraron eventos de bloqueo para el usuario '$UserName' en los últimos 7 días." -ForegroundColor Yellow
        }
    }
    catch [System.Exception] {
        Write-Host "Ocurrió un error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""  # Línea en blanco para separación
} while ($true)

Write-Host "Saliendo del script. ¡Hasta luego!" -ForegroundColor Cyan
