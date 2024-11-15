# Define la ruta de la OU que quieres buscar
$ouPath = "OU=Dominican Republic,OU=Contact_Centers,DC=s2g,DC=net"

# Ruta y nombre de archivo para guardar el reporte CSV

#$csvPath = "C:\Users\la.esantana\Downloads\Scripts"
 
# Inicializa un arreglo para almacenar los resultados

$resultados = @()
 
# Obtiene todos los usuarios de la OU

$usuarios = Get-ADUser -Filter * -SearchBase $ouPath -Properties Name,SamAccountName,Description,EmailAddress
 
# Itera a través de los usuarios y agrega la información al arreglo

foreach ($usuario in $usuarios) {

    $nombre = $usuario.Name
    
    $username = $usuario.SamAccountName

    $descripcion = $usuario.Description
 
    # Verifica si el correo electrónico está disponible

    if ($usuario.EmailAddress) {

        $correo = $usuario.EmailAddress

    } else {

        $correo = "No disponible"

    }
 
    # Crea un objeto personalizado con la información

    $resultado = [PSCustomObject]@{

        Nombre = $nombre

        Usuario = $username

        Descripcion = $descripcion

        Correo = $correo

    }
 
    # Agrega el objeto al arreglo de resultados

    $resultados += $resultado

}
 
# Exporta los resultados a un archivo CSV

$resultados | Export-csv -path C:\Group.csv -NoTypeInformation
 
Write-Host "Reporte generado correctamente en C:"