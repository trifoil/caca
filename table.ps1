Install-Module -Name ImportExcel -Scope CurrentUser

# Import the ImportExcel module
Import-Module ImportExcel

# Define the path to the input Excel file
$inputFilePath = "Employes.xlsx"

# Read the "Liste3" sheet from the Excel file
$sheetData = Import-Excel -Path $inputFilePath -WorksheetName "Liste3"

# Convert all letters to lowercase
$sheetDataLower = $sheetData | ForEach-Object {
    $_.PSObject.Properties | ForEach-Object {
        $_.Value = $_.Value.ToString().ToLower()
    }
    $_
}

# Display the modified sheet in the console
$sheetDataLower | Format-Table -AutoSize

# Define the path to the output Excel file
$outputFilePath = "C:\path\to\output.xlsx"

# Save the modified sheet to a new Excel file
$sheetDataLower | Export-Excel -Path $outputFilePath -WorksheetName "Liste3"
