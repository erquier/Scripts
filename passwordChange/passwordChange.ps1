#This script is for change the password reading a csv file
# Import the Active Directory module
Import-Module ActiveDirectory

# Read data from CSV file
$accounts = Import-Csv -Path "C:\ruta\de\archivo\passwordChange.csv"

# Loop through the list and change passwords
foreach ($account in $accounts) {
    $username = $account.Username
    $newPassword = $account.NewPassword | ConvertTo-SecureString -AsPlainText -Force
    Set-ADAccountPassword -Identity $username -NewPassword $newPassword -Reset
}
