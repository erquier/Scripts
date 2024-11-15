# Importar el módulo Import-Excel
#Import-Module Import-Excel
Import-Module ActiveDirectory

# Ruta al archivo .xlsm o .xlsx
$archivo = "C:\ruta\del\archivo\ADUsernameLookUp.xlsx"

try {
    # Leer el archivo
    $usuarios = Import-Excel -Path $archivo -ErrorAction Stop

    # Leer la OU desde el Excel
    $ouDesdeExcel = $usuarios | Select-Object -ExpandProperty OUDesdeExcel -First 1

    # Inicializar el array para almacenar los resultados
    $resultados = @()

    # Procesar cada usuario
    foreach ($usuarioAD in $usuarios) {
        $nombreUsuario = $usuarioAD.NombreUsuario
        $ouDesdeExcel = $usuarioAD.OUDesdeExcel

        # Verificar si hay información válida
        if ($nombreUsuario -or $ouDesdeExcel) {
            try {
                # Buscar usuarios en la OU especificada o por nombre de usuario
                if ($ouDesdeExcel) {
                    $usuariosAD = Get-ADUser -Filter * -SearchBase $ouDesdeExcel -Properties SamAccountName,MemberOf,EmailAddress,DisplayName,Description -ErrorAction Stop
                } elseif ($nombreUsuario) {
                    $usuariosAD = Get-ADUser -Filter {SamAccountName -eq $nombreUsuario} -Properties SamAccountName,MemberOf,EmailAddress,DisplayName,Description, DistinguishedName -ErrorAction Stop
                }

                # Procesar cada usuario encontrado
                foreach ($usuarioAD in $usuariosAD) {
                    $gruposUsuario = $usuarioAD | Get-ADPrincipalGroupMembership -ErrorAction Stop | Select-Object -ExpandProperty Name
                    $grupos = $gruposUsuario -join ', '

                    # Determinar el dominio del correo
                    $dominioCorreo = if ($usuarioAD.EmailAddress -like '*@yourdomain.com*') {
                        "@yourdomain.comm"
                    } else {
                        "@s2g.net"
                    }

                    # Crear un objeto personalizado con los resultados
                    $resultado = [PSCustomObject]@{
                        NombreUsuario = $usuarioAD.SamAccountName
                        DisplayName = $usuarioAD.DisplayName
                        Description = $usuarioAD.Description
                        GruposAD = $grupos
                        Existe = "Sí"
                        OUDesdeExcel = $ouDesdeExcel
						OUImportado = $usuarioAD.DistinguishedName
                        Correo = $usuarioAD.EmailAddress
                        DominioCorreo = $dominioCorreo
                    }

                    # Agregar el objeto al array
                    $resultados += $resultado
                }
            } catch {
                Write-Host "Error al obtener información del usuario: $_" -ForegroundColor Red
            }
        }
    }

    # Exportar el archivo modificado
    $resultados | Export-Excel -Path $archivo -WorksheetName "Users" -AutoSize -Show -ErrorAction Stop
} catch {
    Write-Host "Error al leer el archivo de Excel: $_" -ForegroundColor Red
}
