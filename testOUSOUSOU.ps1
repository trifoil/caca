# Génération des mdp
function Generate-RandomPassword {
    param (
        [int]$length = 12
    )

    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+=<>?"
    $password = -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return $password
}

# Importation du fichier CSV
$csv = Import-Csv -Path "output.csv"

# Fonction pour créer les OU et sous-OU
function Gestion_OU_SousOU {
    foreach ($line in $csv) {
        $ou = $line.ou
        $sousou = $line.departement

        # Check si l'OU existe déjà
        if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $ou} -SearchBase "DC=belgique,DC=lan" -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $ou -Path "DC=belgique,DC=lan"
            Write-Output "L'OU $ou a été créée"
        } else {
            Write-Output "L'OU $ou existe déjà"
        }

        # Check si le SOUS-OU existe déjà
        if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $sousou} -SearchBase "OU=$ou,DC=belgique,DC=lan" -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $sousou -Path "OU=$ou,DC=belgique,DC=lan"
            Write-Output "Le SOUS-OU $sousou a été créée"
        } else {
            Write-Output "Le SOUS-OU $sousou existe déjà"
        }
    }
}

# Fonction pour créer les groupes globaux
function Gestion_GG {
    $gg_ou_path = "OU=gg,OU=Groupes,DC=belgique,DC=lan"

    # Check si l'OU "Groupes" existe déjà
    if (-not (Get-ADOrganizationalUnit -Filter {Name -eq "Groupes"} -SearchBase "DC=belgique,DC=lan" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name "Groupes" -Path "DC=belgique,DC=lan"
        Write-Output "L'OU 'Groupes' a été créée"
    } else {
        Write-Output "L'OU 'Groupes' existe déjà"
    }

    # Check si l'OU "gg" existe déjà
    if (-not (Get-ADOrganizationalUnit -Filter {Name -eq "gg"} -SearchBase "OU=Groupes,DC=belgique,DC=lan" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name "gg" -Path "OU=Groupes,DC=belgique,DC=lan"
        Write-Output "L'OU 'gg' a été créée"
    } else {
        Write-Output "L'OU 'gg' existe déjà"
    }

    # Ajouter les GG pour chaque OU
    foreach ($line in $csv) {
        $ou = $line.ou
        $gg_name = "GG_${ou}"

        # Check si le GG existe déjà
        if (-not (Get-ADGroup -Filter {Name -eq $gg_name} -SearchBase $gg_ou_path -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $gg_name -GroupScope Global -Path $gg_ou_path
            Write-Output "Le GG $gg_name a été créé"
        } else {
            Write-Output "Le GG $gg_name existe déjà"
        }
    }
}

# Création des Users et ajout dans les OU & SOUS-OU
function Gestion_Users {
    foreach ($line in $csv) {
        # Récupération des valeurs du CSV
        $nom = $line.nom
        $prenom = $line.prenom
        $upn = $line.upn
        $logon_name = "${upn}@belgique.lan"
        $description = $line.description
        $bureau = $line.bureau
        $interne = $line.interne
        $ou = $line.departement
        $pwd = Generate-RandomPassword

        $ou_path = "OU=$ou,DC=belgique,DC=lan"

        # Check si l'OU existe
        if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $ou} -SearchBase "DC=belgique,DC=lan" -ErrorAction SilentlyContinue)) {
            Write-Output "Erreur : L'OU $ou n'existe pas"
            continue
        }

        # Check si l'utilisateur existe déjà
        if (Get-ADUser -Filter {UserPrincipalName -eq $logon_name} -ErrorAction SilentlyContinue) {
            Write-Output "L'utilisateur $nom existe déjà"
            continue
        }

        # Création de l'utilisateur
        try {
            New-ADUser -Name $nom -GivenName $prenom -UserPrincipalName $logon_name -Description $description -Office $bureau -AccountPassword (ConvertTo-SecureString $pwd -AsPlainText -Force) -Enabled $true -Path $ou_path -SamAccountName $nom
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
}

# Appel des fonctions
Gestion_OU_SousOU
Gestion_GG
Gestion_Users
