# Importar los usuarios desde un archivo CSV
$usuarios = Import-Csv -Path 'C:\Users\la.esantana\Downloads\Scripts\New_Hire\officeChange.csv'

# Recorrer cada usuario en el archivo CSV
foreach ($usuario in $usuarios) {
    # Obtener los valores de las columnas
    $username = $usuario.Username
    $office = $usuario.Office

    # Verificar si el usuario existe
    $adUser = Get-ADUser -Filter {SamAccountName -eq $username}
    if ($adUser) {
        # Cambiar el valor de Office
        Set-ADUser -Identity $username -Office $office
        Write-Host "Se cambió el Office del usuario $username a $office."
    } else {
        Write-Host "El usuario $username no existe."
    }
}
