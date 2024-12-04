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

    # Check si l'OU existe déjà
    if (Get-ADOrganizationalUnit -Filter {Name -eq $ou} -SearchBase "DC=belgique,DC=lan" -ErrorAction SilentlyContinue) {
        Write-Output "L'OU $ou existe déjà"
    } else {
        New-ADOrganizationalUnit -Name $ou -Path "DC=belgique,DC=lan"
        Write-Output "L'OU $ou a été créée"
    }
}

# Création des sous OU => récuperer depuis le CSV
foreach ($line in $csv) {
    $ou = $line.ou
    $sousou = $line.departement
    $sousou_path = "OU=$sousou,OU=$ou,DC=belgique,DC=lan"

    # Check si le SOUS-OU existe déjà
    if (Get-ADOrganizationalUnit -Filter {Name -eq $sousou} -SearchBase "OU=$ou,DC=belgique,DC=lan" -ErrorAction SilentlyContinue) {
        Write-Output "Le SOUS-OU $sousou existe déjà"
    } else {
        New-ADOrganizationalUnit -Name $sousou -Path "OU=$ou,DC=belgique,DC=lan"
        Write-Output "Le SOUS-OU $sousou a été créée"
    }
}

# Création des Users et ajout dans les OU & SOUS-OU
foreach ($line in $csv) {
    # Récupération des valeurs du CSV
    $nom = $line.nom
    $prenom = $line.prenom
    $description = $line.description
    $bureau = $line.bureau
    $interne = $line.interne
    $ou = $line.departement
    $pwd = $randomPassword

    # Vérification de l'existence de l'OU et de la sous-OU
    $ou_path = "OU=$ou,DC=belgique,DC=lan"
    
    # Check si l'OU existe
    if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $ou} -SearchBase "DC=belgique,DC=lan" -ErrorAction SilentlyContinue)) {
        Write-Output "Erreur : L'OU $ou n'existe pas"
        continue
    }

    # Création de l'utilisateur
    try {
        New-ADUser -Name $nom -GivenName $prenom -Description $description -Office $bureau -AccountPassword (ConvertTo-SecureString $pwd -AsPlainText -Force) -Enabled $true -Path $ou_path -SamAccountName $nom
        Write-Output "Utilisateur $nom créé"
    }
    catch {
        Write-Output "Erreur lors de la création de l'utilisateur $nom : $_"
    }

    # Exporter User + Departement + MDP dans un fichier CSV pour debug
    $output_user_file_path = "output_user.csv"

    $user_info = [PSCustomObject]@{
        Nom         = $nom
        Departement = $ou
        MotDePasse  = $pwd
    }

    $user_info | Export-Csv -Path $output_user_file_path -Append -NoTypeInformation -Encoding UTF8

}
