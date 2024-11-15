try {
    # Importar el módulo Active Directory
    Import-Module ActiveDirectory -ErrorAction Stop

    # Ruta al archivo Excel
    $archivo = "C:\Users\la.esantana\Downloads\Scripts\New_Hire\New_Hire.xlsx"

    # Leer el archivo Excel
    $usuarios = Import-Excel -Path $archivo -ErrorAction Stop

    # Si solo hay un usuario, establecer un límite de solicitud menor para evitar problemas de tamaño
    $maxRequests = if ($usuarios.Count -eq 1) { 5 } else { 1000 }

    # Establecer el límite de solicitud
    $env:LDAPAdminLimits = "MaxPoolThreads=$maxRequests"

    # Verificar si el entorno es diferente de producción para limitar la acción
    if ($env:USERDOMAIN -ne "production") {
        $maxRequests = 1
    }

    # Recorrer cada usuario en el archivo Excel
    foreach ($usuario in $usuarios) {
        # Obtener los valores de las columnas
        $nombre = $usuario.Nombre
        $apellido = $usuario.Apellido
        $username = $usuario.Username
        $password = $usuario.Password
        $ou = $usuario.OU
        $adGroup = $usuario.ADGroup
        $description = $usuario.Description
        $office = $usuario.Office
		
        # Validar los valores de entrada
        if (-not ($nombre -and $apellido -and $username -and $password -and $ou -and $adGroup -and $description -and $office)) {
            Write-Host "Uno o más valores de entrada son nulos o vacíos para el usuario $username. Por favor, verifique los datos."
            continue
        }

        # Verificar si el usuario ya existe
        if (!(Get-ADUser -Filter {SamAccountName -eq $username})) {
            try {
                # Crear el usuario en Active Directory
                $newUserParams = @{
                    SamAccountName = $username
                    UserPrincipalName = "$username@s2g.net"
                    GivenName = $nombre
                    Surname = $apellido
                    Name = "$nombre $apellido"
                    DisplayName = "$nombre $apellido"
                    Description = $description
                    Office = $office
                    Path = $ou
                    AccountPassword = (ConvertTo-SecureString $password -AsPlainText -Force)
                    Enabled = $true
                    PasswordNeverExpires = $false
                    ChangePasswordAtLogon = $true
                }

                $currentUsername = $username
                $newUser = New-ADUser @newUserParams -ErrorAction Stop

                Write-Host "Usuario $currentUsername creado exitosamente en $ou"

                # Agregar el usuario a los grupos después de la creación
                if ($adGroup) {
                    $adGroups = $adGroup -split ',' | ForEach-Object { $_.Trim() }
                    foreach ($group in $adGroups) {
                        try {
                            # Verificar si el grupo existe
                            if (Get-ADGroup -Identity $group -ErrorAction Stop) {
                                Add-ADGroupMember -Identity $group -Members $currentUsername -ErrorAction Stop
                                Write-Host "Usuario $currentUsername agregado al grupo $group"
                            } else {
                                Write-Host "El grupo ${group} no existe. Por favor, verifique el nombre del grupo."
                            }
                        } catch [Microsoft.ActiveDirectory.Management.ADException] {
                            if ($_.Exception.Message -match "Either the specified user account is already a member of the specified group") {
                                Write-Host "El usuario $currentUsername ya es miembro del grupo $group."
                            } else {
                                Write-Host "Error al agregar usuario $currentUsername al grupo ${group}: $_"
                            }
                        } catch {
                            Write-Host "Error al agregar usuario $currentUsername al grupo ${group}: $_"
                        }
                    }
                }
            } catch {
                Write-Host "Error al procesar usuario ${currentUsername}: $_"
            }
        } else {
            Write-Host "El usuario $username ya existe. Por favor, elija otro nombre de usuario."
        }
    }
} catch {
    Write-Host "Error general: $_"
}