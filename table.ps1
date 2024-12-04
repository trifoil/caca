# Install the ImportExcel module if not already installed
Install-Module -Name ImportExcel -Scope CurrentUser -Force

# Import the ImportExcel module
Import-Module ImportExcel

# Define the path to the input Excel file
$inputFilePath = "Employes.xlsx"

# Read the "Liste3" sheet from the Excel file
$sheetData = Import-Excel -Path $inputFilePath -WorksheetName "Liste3"

# Function to remove diacritics
function Remove-Diacritics {
    param (
        [string]$inputString
    )
    $normalizedString = $inputString.Normalize( [System.Text.NormalizationForm]::FormD )
    $stringBuilder = New-Object System.Text.StringBuilder
    $normalizedString.ToCharArray() | ForEach-Object {
        if ( [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark ) {
            $null = $stringBuilder.Append($_)
        }
    }
    return $stringBuilder.ToString().Normalize( [System.Text.NormalizationForm]::FormC )
}

# Convert all letters to lowercase and remove diacritics
$sheetDataLower = $sheetData | ForEach-Object {
    $_.PSObject.Properties | ForEach-Object {
        $_.Value = (Remove-Diacritics -inputString $_.Value.ToString()).ToLower()
    }
    $_
}

# Convert column names to lowercase and remove diacritics
$sheetDataLower = $sheetDataLower | ForEach-Object {
    $row = $_
    $newRow = New-Object PSObject
    $row.PSObject.Properties | ForEach-Object {
        $columnName = (Remove-Diacritics -inputString $_.Name).ToLower()
        $newRow | Add-Member -MemberType NoteProperty -Name $columnName -Value $_.Value
    }
    $newRow
}

# Append a new column named "ou" and copy the contents of the "departement" column into it
$sheetDataLower = $sheetDataLower | Select-Object *, @{Name="ou";Expression={$_.departement}}

# Remove characters after the "/" character, including the "/" itself, from the "departement" column
$sheetDataLower = $sheetDataLower | ForEach-Object {
    $_.departement = $_.departement -replace '/.*', ''
    $_
}

# Remove characters before the "/" character, including the "/" itself, from the "ou" column
$sheetDataLower = $sheetDataLower | ForEach-Object {
    $_.ou = $_.ou -replace '^[^/]*/', ''
    $_
}

# Remove all spaces, single quotes, "&", and "-" characters in all cells
$sheetDataLower = $sheetDataLower | ForEach-Object {
    $_.PSObject.Properties | ForEach-Object {
        $_.Value = $_.Value -replace ' ', '' -replace "'", '' -replace '&', '' -replace '-', ''
    }
    $_
}

# Change the column title that contains "interne" to "interne"
$sheetDataLower = $sheetDataLower | ForEach-Object {
    $row = $_
    $newRow = New-Object PSObject
    $row.PSObject.Properties | ForEach-Object {
        $columnName = if ($_.Name -match "interne") { "interne" } else { $_.Name }
        $newRow | Add-Member -MemberType NoteProperty -Name $columnName -Value $_.Value
    }
    $newRow
}

# Add a new column called "nomprenomcat"
$sheetDataLower = $sheetDataLower | ForEach-Object {
    $nom = $_.nom
    $prenom = $_.prenom
    $nomprenomcat = "$prenom.$nom"
    if ($nomprenomcat.Length -gt 20) {
        $nomprenomcat = "$($prenom[0]).$nom"
    }
    $_ | Add-Member -MemberType NoteProperty -Name "nomprenomcat" -Value $nomprenomcat
    $_
}

# Display the modified sheet in the console
$sheetDataLower | Format-Table -AutoSize

# Define the path to the output CSV file
$outputFilePath = "output.csv"

# Save the modified sheet to a CSV file
$sheetDataLower | Export-Csv -Path $outputFilePath -NoTypeInformation
