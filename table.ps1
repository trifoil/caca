# Import the required module for Excel operations
Import-Module -Name ImportExcel

# Load the Excel file
$excelFilePath = "Employes.xlsx" # Replace with the path to your file
$data = Import-Excel -Path $excelFilePath

# Convert all columns to lowercase and remove leading/trailing spaces
$data | ForEach-Object {
    foreach ($key in $_.PSObject.Properties.Name) {
        $_.$key = $_.$key -replace '\s+', '' | ForEach-Object { $_.ToLower() }
    }
}

# Detect duplicates based on the first and second columns (Name and Surname)
$duplicates = @{}
$data | ForEach-Object {
    $key = $_.Name + $_.Surname
    if ($duplicates.ContainsKey($key)) {
        $duplicates[$key] += ,$_
    } else {
        $duplicates[$key] = @($_)
    }
}

# Iterate over the duplicates to resolve them
foreach ($key in $duplicates.Keys) {
    $entries = $duplicates[$key]
    if ($entries.Count -gt 1) {
        Write-Host "Found duplicates for: $key"
        foreach ($entry in $entries) {
            Write-Host "Entry: $($entry | Out-String)"
        }

        $choice = Read-Host "Do you want to remove duplicates? (yes/no)"
        if ($choice -eq "yes") {
            # Keep only the first entry
            $duplicates[$key] = @($duplicates[$key][0])
        } else {
            # Rename entries
            for ($i = 1; $i -lt $entries.Count; $i++) {
                $newName = Read-Host "Enter new Name for duplicate $i"
                $entries[$i].Name = $newName
            }
        }
    }
}

# Flatten the results into a new 2D array
$cleanedData = @()
foreach ($key in $duplicates.Keys) {
    $cleanedData += $duplicates[$key]
}

# Remove spaces in all columns for the final result
$cleanedData | ForEach-Object {
    foreach ($key in $_.PSObject.Properties.Name) {
        $_.$key = $_.$key -replace '\s+', ''
    }
}

# Export the modified data back to an Excel file
$exportPath = "path_to_cleaned_Employes.xlsx" # Replace with your desired output file path
$cleanedData | Export-Excel -Path $exportPath -WorksheetName "CleanedData"

Write-Host "Processing complete. Cleaned data exported to $exportPath."
