param (
    [Alias("i", "I")]
    [switch]$Install,
    [Alias("u","U")]
    [switch]$Uninstall
)
# params checks
if ($PSBoundParameters.Count -gt 1) {
    Write-Host "Please specify either -[I]nstall or -[U]ninstall and not both. This isn't Schrödinger's cat, it cannot exit in both states."
}
if ($PSBoundParameters.Count -lt 1) {
    Write-Host "Please specify either -[I]nstall or -[U]ninstall and not nothing. You have to install something."
}
if ($PSBoundParameters.Count -lt 0) {
    Write-Host "Inconceivable!"
}

# Import the InstallTerminalModule module
Import-Module -Name "..\InstallTerminalModule.psm1"

# Define parameters
$repo = "microsoft/terminal"
# Get the latest release version of Windows Terminal
$latestVersion = Get-LatestReleaseVersion -repo $repo
Write-Host "Latest Windows Terminal version: $latestVersion"

# Install or Uninstall Windows Terminal based on the provided parameter
if ($Install) {
    Write-Host "Installing Windows Terminal..."
    Install-WindowsTerminal -workingDirectory $workingDirectory
} elseif ($Uninstall) {
    Write-Host "Uninstalling Windows Terminal..."
    Uninstall-WindowsTerminal -workingDirectory $workingDirectory
}  else {
    Write-Host "Please specify either -[I]nstall or -[U]ninstall."
}