# Création des OU 
$csv = Import-Csv -Path "C:\FUCKONEDRIVE\ProjetWinServ\SCRIPT\output.csv"
foreach ($line in $csv) {
    $ou = $line.ou
    New-ADOrganizationalUnit -Name $ou -Path "DC=belgique,DC=lan"
}

# Création des sous OU => récuperer depuis le CSV
$csv = Import-Csv -Path "C:\FUCKONEDRIVE\ProjetWinServ\SCRIPT\output.csv"
foreach ($line in $csv) {
    $ou = $line.ou
    $sousou = $line.departement
    New-ADOrganizationalUnit -Name $sousou -Path "OU=$ou,DC=belgique,DC=lan"
}
