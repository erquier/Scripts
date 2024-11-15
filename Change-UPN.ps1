# Import the Active Directory module
Import-Module ActiveDirectory

# Define the old and new UPN suffix
$oldSuffix = "@yourdomain"
$newSuffix = "@newdomain"

# Ask for the username
$userName = Read-Host -Prompt 'Enter the username'

# Get the AD user
$user = Get-ADUser -Identity $userName -Properties UserPrincipalName

# Change the UPN suffix
$newUpn = $user.UserPrincipalName.Replace($oldSuffix, $newSuffix)
Set-ADUser -Identity $user.SamAccountName -UserPrincipalName $newUpn
