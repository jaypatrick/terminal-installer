param (
    [Alias("i", "I")]
    [switch]$Install,
    [Alias("u", "U")]
    [switch]$Uninstall
)

# Parameter checks
if ($PSBoundParameters.Count -eq 0) {
    Write-Host "Please specify either -[I]nstall or -[U]ninstall."
    exit
}

if ($Install -and $Uninstall) {
    Write-Host "Please specify either -[I]nstall or -[U]ninstall, not both."
    exit
}

# Import the InstallTerminalModule module
Import-Module -Name "..\InstallTerminalModule.psm1"

# Read configuration file
try {
    $config = Get-Config -configFilePath "..\config\terminal-config.json"
    $repo = $config.terminalPackageRepo
    $workingDirectory = "..\$($config.terminalWorkingDirectory)"
} catch {
    Write-Error "Failed to read configuration file. Error: $_"
    exit
}

# Get the latest release version of Windows Terminal
try {
    $latestVersion = Get-LatestReleaseVersion -repo $repo
    Write-Host "Latest Windows Terminal version: $latestVersion"
} catch {
    Write-Error "Failed to get the latest release version. Error: $_"
    exit
}

# Install or Uninstall Windows Terminal based on the provided parameter
if ($Install) {
    Write-Host "Installing Windows Terminal..."
    Install-WindowsTerminal -workingDirectory $workingDirectory -version $latestVersion
} elseif ($Uninstall) {
    Write-Host "Uninstalling Windows Terminal..."
    Uninstall-WindowsTerminal -workingDirectory $workingDirectory
} else {
    Write-Host "Please specify either -[I]nstall or -[U]ninstall."
}