# Importar el módulo de Active Directory
Import-Module ActiveDirectory

# Definir las rutas de origen y destino
$SourceOU = "OU=origin"
$DestinationOU = "OU=destination"

# Obtener todas las computadoras que comienzan con "SA2-D-" en la OU de origen
$Computers = Get-ADComputer -SearchBase $SourceOU -Filter { Name -like "PC-D-*" }

# Inicializar contadores
$TotalComputers = $Computers.Count
$MovedCount = 0
$FailedCount = 0
$FailedComputers = @()

# Inicializar barra de progreso
$Counter = 0

foreach ($Computer in $Computers) {
    $Counter++
    Write-Progress -Activity "Moviendo computadoras" -Status "Procesando $Counter de $TotalComputers" -PercentComplete (($Counter / $TotalComputers) * 100)

    try {
        # Mover el objeto de la computadora
        Move-ADObject -Identity $Computer.DistinguishedName -TargetPath $DestinationOU -ErrorAction Stop
        $MovedCount++
    }
    catch {
        $FailedCount++
        $FailedComputers += [PSCustomObject]@{
            Nombre = $Computer.Name
            Razon  = $_.Exception.Message
        }
    }
}

# Mostrar resultados
Write-Host "`nTotal de computadoras procesadas: $TotalComputers"
Write-Host "Computadoras movidas exitosamente: $MovedCount"
Write-Host "Computadoras que no se pudieron mover: $FailedCount"

if ($FailedCount -gt 0) {
    Write-Host "`nDetalles de los errores:"
    $FailedComputers | Format-Table Nombre, Razon -AutoSize
}
