param (
    [string]$repo = "microsoft/terminal",
    [string]$workingDirectory
)

# Define the module path assuming it's in the same directory as the script
$modulePath = ".\InstallTerminalModule.psm1"

# Check if the module exists
if (-not (Test-Path -Path $modulePath)) {
    Write-Host "The module InstallTerminalModule.psm1 does not exist in the directory: $($PSScriptRoot)"
    exit 1
}

# Import the module
Import-Module -Name $modulePath

# Prompt user for the working directory if not provided
if (-not $workingDirectory) {
    $workingDirectory = Read-Host -Prompt "Enter the working directory"
}

# Install Windows Terminal
Install-WindowsTerminal -repo $repo -workingDirectory $workingDirectory

<#
Usage
You can now run the script with command-line parameters like this:

.\install-terminal.ps1 -repo "microsoft/terminal" -workingDirectory "C:\Path\To\WorkingDirectory"
Or, if you want to use the default repository and prompt for the working directory:

.\install-terminal.ps1 -workingDirectory "C:\Path\To\WorkingDirectory"
Or, if you want to prompt for both parameters:

.\install-terminal.ps1
#>