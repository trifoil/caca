# Define the new server name
$NewServerName = "MyNewServerName"

# Get the current computer name
$CurrentServerName = (Get-WmiObject Win32_ComputerSystem).Name

# Check if the new name is already applied
if ($CurrentServerName -eq $NewServerName) {
    Write-Host "The server name is already set to $NewServerName."
} else {
    # Change the computer name
    Rename-Computer -NewName $NewServerName -Force

    # Notify the user and reboot the system
    Write-Host "Server name changed to $NewServerName. The server will now reboot."
    Restart-Computer -Force
}
