# Instalar el módulo ImportExcel si no está instalado
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    try {
        Install-Module -Name ImportExcel -Force -SkipPublisherCheck
    } catch {
        Write-Host "Error al instalar el módulo ImportExcel: $_"
        exit
    }
}

# Cargar el módulo ImportExcel
try {
    Import-Module ImportExcel
} catch {
    Write-Host "Error al cargar el módulo ImportExcel: $_"
    exit
}

# Seleccionar el archivo Excel
try {
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "Excel Files|*.xlsx;*.xlsm;*.xlsb;*.xls"
    if ($OpenFileDialog.ShowDialog() -eq 'OK') {
        $excelFilePath = $OpenFileDialog.FileName
    } else {
        throw "No se seleccionó ningún archivo."
    }
} catch {
    Write-Host "Error al seleccionar el archivo Excel: $_"
    exit
}

# Leer el archivo Excel
try {
    $data = Import-Excel -Path $excelFilePath
    if (-not $data) {
        throw "No se leyeron datos del archivo Excel."
    }

    Write-Host "Datos leídos del archivo Excel:"
    $data | Format-Table -AutoSize
} catch {
    Write-Host "Error al leer el archivo Excel: $_"
    exit
}

# Procesar cada fila
try {
    foreach ($row in $data) {
        $firstName = $row.Nombre
        $lastName = $row.Apellido
        $currentUsername = $row.Username

        if ($firstName -and $lastName) {
            # Generar el nuevo nombre de usuario según el formato
            $newUsername = ($firstName[0..1] -join '').ToLower() + $lastName.ToLower() -replace '\s', ''
            $counter = 2

            # Verificar si el nuevo nombre de usuario ya existe en AD
            $exists = $false
            try {
                $exists = Get-ADUser -Filter "SamAccountName -eq '$newUsername'" -ErrorAction Stop
            } catch {
                $exists = $false
            }

            while ($exists) {
                $newUsername = ($firstName[0..($counter - 1)] -join '').ToLower() + $lastName.ToLower() -replace '\s', ''
                $counter++

                try {
                    $exists = Get-ADUser -Filter "SamAccountName -eq '$newUsername'" -ErrorAction Stop
                } catch {
                    $exists = $false
                }
            }

            # Actualizar la columna 'Username_updated'
            if (-not $row.PSObject.Properties['Username_updated']) {
                $row.PSObject.Properties.Add((New-Object PSNoteProperty 'Username_updated' $newUsername))
            } else {
                $row.Username_updated = $newUsername
            }

            Write-Host "Nombre de usuario actualizado: $newUsername"
        } else {
            Write-Host "Fila con datos incompletos: Nombre=$firstName, Apellido=$lastName, Username=$currentUsername"
        }
    }

    # Guardar los cambios en el archivo Excel
    $data | Export-Excel -Path $excelFilePath -Show
    Write-Host "Los cambios se guardaron en el archivo Excel."
} catch {
    Write-Host "Error al procesar los datos o guardar los cambios: $_"
}
