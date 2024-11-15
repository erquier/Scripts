# Importar el módulo de Active Directory
Import-Module ActiveDirectory

Clear-Host

do {
    try {
        # Solicitar el nombre de usuario
        $username = Read-Host "Ingrese el nombre de usuario para desbloquear (o escriba 'salir' para terminar)"

        if ($username.ToLower() -eq 'salir') {
            break
        }

        # Verificar si el usuario existe
        $user = Get-ADUser -Identity $username -Properties LockedOut -ErrorAction Stop

        # Verificar si la cuenta está bloqueada
        if ($user.LockedOut) {
            # Desbloquear la cuenta
            Unlock-ADAccount -Identity $username -ErrorAction Stop
            Write-Host "La cuenta de usuario '$username' ha sido desbloqueada." -ForegroundColor Green
        } else {
            Write-Host "La cuenta de usuario '$username' no está bloqueada." -ForegroundColor Yellow
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Host "El usuario '$username' no se encontró en Active Directory." -ForegroundColor Red
    }
    catch {
        Write-Host "Ocurrió un error: $_.Exception.Message" -ForegroundColor Red
    }

    Write-Host ""  # Línea en blanco para separación
} while ($true)

Write-Host "Saliendo del script. ¡Hablamo el malte!" -ForegroundColor Cyan
