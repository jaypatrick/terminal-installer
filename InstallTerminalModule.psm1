# Import necessary module
Import-Module Appx

# Function to get the latest release version from GitHub
function Get-LatestReleaseVersion {
    param (
        [string]$repo
    )
    $url = "https://api.github.com/repos/$repo/releases/latest"
    $response = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "PowerShell" }
    return $response.tag_name.TrimStart('v')
}

# Function to check if a URL exists
function Test-Url {
    param (
        [string]$url
    )
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Function to install Windows Terminal
function Install-WindowsTerminal {
    param (
        [string]$workingDirectory
    )

    # Get the latest terminal version
    $repo = "microsoft/terminal"
    $terminalVersionString = Get-LatestReleaseVersion -repo $repo

    # terminal package strings
    $terminalPackageUrl = "https://github.com/microsoft/terminal/releases/download/v$($terminalVersionString)/Microsoft.WindowsTerminal_$($terminalVersionString)_8wekyb3d8bbwe.msixbundle"
    $terminalPackageOutName = "Microsoft.WindowsTerminal_$($terminalVersionString)_8wekyb3d8bbwe.msixbundle"

    # prerequisite strings
    $vcLibrariesPackageUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $vcLibrariesOutName = "Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $microsoftUiXamlUrl = "https://github.com/microsoft/terminal/releases/download/v$($terminalVersionString)/Microsoft.WindowsTerminal_$($terminalVersionString)_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip"
    $microsoftUiXamlOutName = "Microsoft.WindowsTerminal_$($terminalVersionString)_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip"

    $microsoftUiXamlFileExtensionToInstall = "*.msixbundle"

    # Check if the terminal is already installed
    $terminalPackageName = "Microsoft.WindowsTerminal"
    $installedPackage = Get-AppxPackage -Name $terminalPackageName -ErrorAction SilentlyContinue

    if ($installedPackage) {
        Write-Host "Windows Terminal is already installed. Version: $($installedPackage.Version)"
        return
    }

    # Check if the terminal package URL exists
    if (-not (Test-Url -url $terminalPackageUrl)) {
        Write-Host "The terminal package URL does not exist: $terminalPackageUrl"
        return
    }

    # Check if the prerequisite URLs exist
    if (-not (Test-Url -url $vcLibrariesPackageUrl)) {
        Write-Host "The VC Libraries package URL does not exist: $vcLibrariesPackageUrl"
        return
    }

    if (-not (Test-Url -url $microsoftUiXamlUrl)) {
        Write-Host "The Microsoft UI XAML package URL does not exist: $microsoftUiXamlUrl"
        return
    }

    # Install Prerequisites
    Invoke-WebRequest -Uri $vcLibrariesPackageUrl -outfile $workingDirectory\$vcLibrariesOutName
    Add-AppxPackage $vcLibrariesOutName
    Invoke-WebRequest -Uri $microsoftUiXamlUrl -OutFile $workingDirectory\$microsoftUiXamlOutName

    # Expand the archive and install the pre-req
    Expand-Archive -LiteralPath "$workingDirectory\$microsoftUiXamlOutName" -DestinationPath "$workingDirectory" -Force
    Remove-Item -LiteralPath "$workingDirectory\$microsoftUiXamlOutName" -Confirm -Force

    # Find the file with the msixbundle file, and execute it. It will select the correct system architecture to install, no need for messy WMI calls
    $microsoftUiXamlMsixbundel = Get-ChildItem -Path $workingDirectory -Filter $microsoftUiXamlFileExtensionToInstall -Recurse -File | Select-Object -First 1
    Add-AppxPackage -Path $microsoftUiXamlMsixbundel.FullName

    # Download Terminal
    Invoke-WebRequest -Uri $terminalPackageUrl -outfile $workingDirectory\$terminalPackageOutName

    # Install Terminal
    Add-AppxPackage -Path $workingDirectory\$terminalPackageOutName
}