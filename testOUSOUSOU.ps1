# Création d'un script permettant de créer des USERS sur l'AD
# 1. Création des Groupes Globaux
# 2. Création des Groupes Locaux
# 3. Ajouts des utilisateurs du fichier CSV dans les Groupes Globaux

# Génération des mdp
function Generate-RandomPassword {
    param (
        [int]$length = 7
    )

    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+=<>?"
    $password = -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return $password
}
$randomPassword = Generate-RandomPassword
Write-Output "Mot de passe généré : $randomPassword"

# Création des OU 
$csv = Import-Csv -Path "output.csv"
foreach ($line in $csv) {
    $ou = $line.ou
    $ou_path = "OU=$ou,DC=belgique,DC=lan"

    #Check si l'OU existe déjà
    if (Get-ADOrganizationalUnit -Filter {Name -eq $ou} -SearchBase $ou_path) {
        Write-Output "L'OU $ou existe déjà"
    } else {
        New-ADOrganizationalUnit -Name $ou -Path $ou_path
    }
}

# Création des sous OU => récuperer depuis le CSV
$csv = Import-Csv -Path "output.csv"
foreach ($line in $csv) {
    $ou = $line.ou
    $sousou = $line.departement

    #Check si le SOUS-OU existe déjà
    if (Get-ADOrganizationalUnit -Filter {Name -eq $sousou} -SearchBase "OU=$ou,DC=belgique,DC=lan") {
        Write-Output "Le SOUS-OU $sousou existe déjà"
    } else {
        New-ADOrganizationalUnit -Name $sousou -Path "OU=$ou,DC=belgique,DC=lan"
    }
}

