<#
.SYNOPSIS
    Installs Windows Terminal from the specified GitHub repository.

.DESCRIPTION
    The Install-WindowsTerminal function downloads and installs Windows Terminal from the specified GitHub repository.
    It ensures the bin directory exists, downloads the terminal package, and installs it.

.PARAMETER repo
    The GitHub repository from which to download Windows Terminal. Default is "microsoft/terminal".

.PARAMETER workingDirectory
    The directory where the Windows Terminal package will be downloaded and installed.

.EXAMPLE
    Install-WindowsTerminal -repo "microsoft/terminal" -workingDirectory "C:\Path\To\WorkingDirectory"
    Installs Windows Terminal from the "microsoft/terminal" repository to the specified working directory.

.EXAMPLE
    Install-WindowsTerminal -workingDirectory "C:\Path\To\WorkingDirectory"
    Installs Windows Terminal from the default "microsoft/terminal" repository to the specified working directory.

.NOTES
    Make sure the working directory exists or the function will create it.
#>
function Install-WindowsTerminal {
    param (
        [string]$repo = "microsoft/terminal",
        [string]$workingDirectory
    )

    # Get the latest terminal version
    $terminalVersionString = Get-LatestReleaseVersion -repo $repo

    # Define the bin directory path
    $binDirectory = Join-Path -Path $workingDirectory -ChildPath ".\bin"

    # Ensure the bin directory exists
    if (-not (Test-Path -Path $binDirectory)) {
        New-Item -ItemType Directory -Path $binDirectory -Force
    }

    # Define terminal package strings
    $terminalPackageUrl = "https://github.com/$repo/releases/download/v$($terminalVersionString)/Microsoft.WindowsTerminal_$($terminalVersionString)_8wekyb3d8bbwe.msixbundle"
    $terminalPackageOutName = "Microsoft.WindowsTerminal_$($terminalVersionString)_8wekyb3d8bbwe.msixbundle"

    # Define the terminal package path in the bin directory
    $terminalPackagePath = Join-Path -Path $binDirectory -ChildPath $terminalPackageOutName

    # Download the terminal package, overwriting if it exists
    Invoke-WebRequest -Uri $terminalPackageUrl -OutFile $terminalPackagePath -Force

    # Add the app package
    Add-AppxPackage -Path $terminalPackagePath
}

# Example call to install Windows Terminal from the default repository
# Install-WindowsTerminal -workingDirectory "C:\Path\To\WorkingDirectory"