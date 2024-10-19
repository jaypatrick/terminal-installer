# Import the module
Import-Module -Name "C:\Path\To\InstallTerminalModule.psm1"

# Prompt user for the working directory
$workingDirectory = Read-Host -Prompt "Enter the working directory"

# Install Windows Terminal
Install-WindowsTerminal -workingDirectory $workingDirectory