Import-Module ActiveDirectory

do {
    # Solicitar y verificar la OU
    do {
        $ou = Read-Host "Por favor, ingrese la ruta de la OU en la que desea buscar (o escriba 'salir' para terminar):"
        if ($ou.ToLower() -eq "salir") {
            break 2  # Sale de ambos bucles
        }
        try {
            $ouCheck = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'"
            if ($ouCheck) {
                break  # La OU existe, salir del bucle interno
            } else {
                Write-Host "La OU especificada no existe. Por favor, intente nuevamente."
            }
        } catch {
            Write-Host "Error al verificar la OU. Por favor, asegúrese de que la ruta de la OU es correcta."
        }
    } while ($true)

    # Solicitar y verificar los grupos de seguridad
    do {
        $groupInput = Read-Host "Por favor, ingrese el nombre o nombres de los grupos de seguridad a los que desea agregar los usuarios (separados por comas), o escriba 'salir' para terminar:"
        if ($groupInput.ToLower() -eq "salir") {
            break 2  # Sale de ambos bucles
        }

        # Separar los nombres de grupos y eliminar espacios adicionales
        $groupNames = $groupInput.Split(",") | ForEach-Object { $_.Trim() }

        # Verificar que cada grupo existe
        $allGroupsExist = $true
        $groupChecks = @()

        foreach ($groupName in $groupNames) {
            try {
                $groupCheck = Get-ADGroup -Identity $groupName -ErrorAction Stop
                $groupChecks += $groupCheck
            } catch {
                Write-Host "El grupo '$groupName' no existe. Por favor, verifique los nombres e intente nuevamente."
                $allGroupsExist = $false
                break
            }
        }

        if ($allGroupsExist) {
            break  # Todos los grupos existen, salir del bucle interno
        }
    } while ($true)

    # Obtiene los usuarios de la OU especificada
    try {
        $users = Get-ADUser -Filter * -SearchBase $ou -SearchScope Subtree
    } catch {
        Write-Host "Error al obtener los usuarios. Asegúrese de que la ruta de la OU es correcta."
        continue
    }

    if (!$users) {
        Write-Host "No se encontraron usuarios en la OU especificada."
    } else {
        # Contadores para el resumen
        $summary = @{}

        foreach ($groupCheck in $groupChecks) {
            $groupName = $groupCheck.Name
            $summary[$groupName] = @{
                AddedCount = 0
                AlreadyMemberCount = 0
            }
        }

        # Procesa cada usuario
        foreach ($user in $users) {
            try {
                # Obtener los grupos del usuario
                $userMemberOf = (Get-ADUser $user.SamAccountName -Properties MemberOf).MemberOf

                foreach ($groupCheck in $groupChecks) {
                    $groupDN = $groupCheck.DistinguishedName
                    $groupName = $groupCheck.Name

                    if ($userMemberOf -contains $groupDN) {
                        $summary[$groupName].AlreadyMemberCount++
                    } else {
                        # Agrega al usuario al grupo
                        try {
                            Add-ADGroupMember -Identity $groupCheck.SamAccountName -Members $user.SamAccountName -ErrorAction Stop
                            $summary[$groupName].AddedCount++
                        } catch {
                            Write-Host "Error al agregar $($user.SamAccountName) al grupo '$groupName'. Verifique que tiene los permisos necesarios."
                        }
                    }
                }
            } catch {
                Write-Host "Error al procesar $($user.SamAccountName). Verifique que tiene los permisos necesarios."
            }
        }

        # Mostrar resumen
        Write-Host "Proceso completado."
        foreach ($groupName in $summary.Keys) {
            $added = $summary[$groupName].AddedCount
            $alreadyMember = $summary[$groupName].AlreadyMemberCount
            Write-Host "$added usuarios fueron agregados al grupo '$groupName'."
            Write-Host "$alreadyMember usuarios ya eran miembros del grupo '$groupName'."
        }
    }

} while ($true)
