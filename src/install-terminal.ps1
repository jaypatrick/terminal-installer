<#
.SYNOPSIS
    This script installs Windows Terminal from the specified GitHub repository.

.DESCRIPTION
    The install-terminal.ps1 script downloads and installs Windows Terminal from the specified GitHub repository.
    If the working directory is not provided, the script will prompt the user to enter it.

.PARAMETER repo
    The GitHub repository from which to download Windows Terminal. Default is "microsoft/terminal".

.PARAMETER workingDirectory
    The directory where the Windows Terminal package will be downloaded and installed. If not provided, the script will prompt the user to enter it.

.EXAMPLE
    .\install-terminal.ps1 -repo "microsoft/terminal" -workingDirectory "C:\Path\To\WorkingDirectory"
    Installs Windows Terminal from the "microsoft/terminal" repository to the specified working directory.

.EXAMPLE
    .\install-terminal.ps1 -workingDirectory "C:\Path\To\WorkingDirectory"
    Installs Windows Terminal from the default "microsoft/terminal" repository to the specified working directory.

.EXAMPLE
    .\install-terminal.ps1 -repo "microsoft/terminal"
    Installs Windows Terminal from the "microsoft/terminal" repository and prompts the user to enter the working directory.

.NOTES
    Make sure you are in the directory where the install-terminal.ps1 script is located or provide the correct relative path to the script.
#>
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
    To call the install-terminal.ps1 script from the command line, you can use the following PowerShell command:

    With Both Parameters (repo and workingDirectory):
    .\install-terminal.ps1 -repo "microsoft/terminal" -workingDirectory "C:\Path\To\WorkingDirectory"
    With Default Repository and Specified Working Directory
    .\install-terminal.ps1 -workingDirectory "C:\Path\To\WorkingDirectory"
    With Default Working Directory and Specified Repository
    .\install-terminal.ps1 -repo "microsoft/terminal"

    Make sure you are in the directory where the install-terminal.ps1 script is located or provide the correct relative path to the script.
#>