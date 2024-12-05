$baseOU = "DC=belgique,DC=lan"




# Fonction de génération de mots de passe
function Generate-RandomPassword {
    param ([int]$Length)

    $Uppercase = (65..90 | ForEach-Object { [char]$_ })
    $Lowercase = (97..122 | ForEach-Object { [char]$_ })
    $Digits = '0'..'9'
    $SpecialChars = @('!', '@', '#', '$', '&', '*', '-', '?')

    # Générer les 4 premiers caractères garantis
    $Password = @(
        ($Uppercase | Get-Random),
        ($Lowercase | Get-Random),
        ($Digits | Get-Random),
        ($SpecialChars | Get-Random)
    )

    # Compléter avec des caractères aléatoires jusqu'à la longueur demandée
    $Password += ($Uppercase + $Lowercase + $Digits + $SpecialChars | Get-Random -Count ($Length - 4))

    # Mélanger les caractères et retourner le mot de passe
    return ($Password | Sort-Object { Get-Random }) -join ''
}



# Fonction de vérification de l'OU
function Verif_OU {
    param (
        [string]$path_OU
    )

    try {
        $boolOU = Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $path_OU } -ErrorAction SilentlyContinue
        if (-not $boolOU) {
            $nom_OU = ($path_OU -split ",")[0] -replace "OU=", ""
            $departementParent = ($path_OU -split ",", 2)[1]

            # Vérification si le parent existe et appel récursif
            Verif_OU -path_OU $departementParent

            # Création de l'OU
            New-ADOrganizationalUnit -Name $nom_OU -Path $departementParent
            Write-Host "L'OU $path_OU a été créée avec succès."

            # Création des groupes GG et GL
            if ($nom_OU -ne "GG" -and $nom_OU -ne "GL") {
            New-ADGroup -GroupScope "Global" -Name "GG_$nom_OU" -Path "OU=GG,OU=Groups,$baseOU"
            New-ADGroup -GroupScope "DomainLocal" -Name "GL_R_$nom_OU" -Path "OU=GL,OU=Groups,$baseOU"
            New-ADGroup -GroupScope "DomainLocal" -Name "GL_RW_$nom_OU" -Path "OU=GL,OU=Groups,$baseOU"}
            
        }
    } catch {
        Write-Host "Erreur lors de la vérification ou création de l'OU $path_OU : $_"
    }
}

# Création des OUs de base
Verif_OU -path_OU "OU=GG,OU=Groups,$baseOU"
Verif_OU -path_OU "OU=GL,OU=Groups,$baseOU"

# Création des utilisateurs et ajout dans les OUs
foreach ($line in $csv) {
    # Récupération des valeurs du CSV
    $nom = $line.nom
    $prenom = $line.prenom
    $description = $line.description
    $departement = $line.departement
    $interne = $line.interne
    $bureau = $line.bureau
    $sousdepartement = $line.ou
    $domain = "$departement.lan"
    $upn = $line.upn

    # Génération du mot de passe en fonction du département
    $pwd =   Generate-RandomPassword -Length 7 

    # Définir l'OU pour l'utilisateur
    $userOU = if ($departement -match $sousdepartement) { "OU=$departement,$baseOU" } else { "OU=$departement,OU=$sousdepartement,$baseOU" }

    # Vérification de l'OU
    Verif_OU -path_OU $userOU

    # Création de l'utilisateur
    try {
        New-ADUser -Name ($prenom + "." + $nom) `
            -GivenName $prenom `
            -Surname $nom `
            -UserPrincipalName $upn@$domain `
            -Description $description `
            -Office $bureau `
            -AccountPassword (ConvertTo-SecureString $pwd -AsPlainText -Force) `
            -Enabled $true `
            -Path $userOU `
            -SamAccountName $upn
        Write-Output "Utilisateur $nom créé"
    } catch {
        Write-Output "Erreur lors de la création de l'utilisateur $nom : $_"
    }

     Add-ADGroupMember -Identity "GG_$departement" -Members $upn
     Add-ADGroupMember -Identity "GG_$sousdepartement" -Members $upn

    # Export des informations utilisateur dans un fichier CSV pour débogage
    $output_user_file_path = "output_user.csv"
    $user_info = [PSCustomObject]@{
        Upn         = $upn
        Departement = $departement
        MotDePasse  = $pwd
    }
    $user_info | Export-Csv -Path $output_user_file_path -Append -NoTypeInformation -Encoding UTF8
}
