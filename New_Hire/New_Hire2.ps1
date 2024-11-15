try {
    # Pedir al usuario que seleccione el archivo Excel
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = "C:\Users\la.esantana\Downloads\Scripts\New_Hire"
    $openFileDialog.Filter = "Archivos Excel (*.xlsx)|*.xlsx|Todos los archivos (*.*)|*.*"
    $openFileDialog.Title = "Seleccione el archivo Excel"

    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $archivo = $openFileDialog.FileName

        # Importar el módulo Active Directory
        Import-Module ActiveDirectory -ErrorAction Stop

        # Importar el módulo Import-Excel
        #Import-Module Import-Excel -ErrorAction Stop

        # Leer el archivo Excel
        $usuarios = Import-Excel -Path $archivo -ErrorAction Stop

    # Recorrer cada usuario en el archivo Excel
    foreach ($usuario in $usuarios) {
        try {
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
                throw "Uno o más valores de entrada son nulos o vacíos para el usuario $username. Por favor, verifique los datos."
            }

            # Verificar si el usuario ya existe
            while (Get-ADUser -Filter {SamAccountName -eq $username}) {
                Write-Host "El usuario $username ya existe. Por favor, elija otro nombre de usuario."
                $username = Read-Host "Por favor, ingrese un nuevo nombre de usuario"
            }

            # Crear el usuario en Active Directory
                $newUserParams = @{
                    # Detalles del usuario...
                }

                $currentUsername = $username
                $newUser = New-ADUser @newUserParams -ErrorAction Stop

                # Agregar el usuario a los grupos después de crearlo
                if ($adGroup) {
                    $adGroups = $adGroup -split ',' | ForEach-Object { $_.Trim() }
                    foreach ($group in $adGroups) {
                        try {
                            if (Get-ADGroup -Identity $group -ErrorAction Stop) {
                                Add-ADGroupMember -Identity $group -Members $currentUsername -ErrorAction Stop
                                Write-Host "Usuario $currentUsername agregado al grupo $group"
                            } else {
                                Write-Host "El grupo ${group} no existe. Por favor, verifique el nombre del grupo."
                            }
                        } catch {
                            Write-Host "Error al agregar usuario $currentUsername al grupo ${group}: $_"
                        }
                    }
                }

                Write-Host "Usuario $currentUsername creado exitosamente en $ou y agregado a los grupos: $adGroup"
            } catch {
                Write-Host "Error al procesar usuario ${currentUsername}: $_"
            }
        }
    } else {
        Write-Host "No se seleccionó ningún archivo. El proceso ha sido cancelado."
    }
} catch {
    Write-Host "Error general: $_"
}
