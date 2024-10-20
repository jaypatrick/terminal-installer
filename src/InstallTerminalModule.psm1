# Import necessary module
Import-Module Appx

# Function to get the latest release version from GitHub
function Get-LatestReleaseVersion {
    param (
        [Alias("r")]
        [string]$repo
    )
    $url = "https://api.github.com/repos/$repo/releases/latest"
    $response = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "PowerShell" }
    return $response.tag_name.TrimStart('v')
}

# Function to check if a URL exists
function Test-Url {
    param (
        [Alias("u")]
        [string]$url
    )
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -ErrorAction Stop
        $response.StatusCode = 200
    } catch {
        $response.StatusCode = 404
    }

    return Response.StatusCode -eq 200 ? $true : $false
}

# Function to install Windows Terminal
function Install-WindowsTerminal {
    param (
        [Alias("wd", "dir")]
        [string]$workingDirectory = "..\bin",
        [Alias("v")]
        [string]$version = ""   #leave blank for latest build, the default
    )

    try {
        # Create the working directory if it does not exist
        if (-not (Test-Path -Path $workingDirectory)) {
            New-Item -ItemType Directory -Path $workingDirectory | Out-Null
        }
    } catch {
        Write-Host "Failed to create working directory: $workingDirectory"
        return
    }

    try {
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
        Write-Host "Checking if the terminal package URL exists: $terminalPackageUrl"
        if (-not (Test-Url -url $terminalPackageUrl)) {
            Write-Host "The terminal package URL for version $terminalVersionString is not valid (check the string format again. No letters allowed.): $terminalPackageUrl"
            return
        }

        # Check if the prerequisite URLs exist
        Write-Host "Checking if the VC Libraries package URL exists: $vcLibrariesPackageUrl"
        if (-not (Test-Url -url $vcLibrariesPackageUrl)) {
            Write-Host "The VC Libraries package URL does not exist: $vcLibrariesPackageUrl"
            return
        }

        Write-Host "Checking if the Microsoft UI XAML package URL exists: $microsoftUiXamlUrl"
        if (-not (Test-Url -url $microsoftUiXamlUrl)) {
            Write-Host "The Microsoft UI XAML package URL does not exist: $microsoftUiXamlUrl"
            return
        }

        # Install Prerequisites
        try {
            Write-Host "Downloading VC Libraries from $vcLibrariesPackageUrl"
            Invoke-WebRequest -Uri $vcLibrariesPackageUrl -outfile $workingDirectory\$vcLibrariesOutName -ErrorAction Stop
            Write-Host "Installing VC Libraries from $workingDirectory\$vcLibrariesOutName"
            Add-AppxPackage -Path "$workingDirectory\$vcLibrariesOutName" -ErrorAction Stop
            Write-Host "VC Libraries installed successfully."
        } catch {
            Write-Error "Failed to install VC Libraries: $_"
            throw
        }

        try {
            Write-Host "Downloading Microsoft UI XAML from $microsoftUiXamlUrl"
            Invoke-WebRequest -Uri $microsoftUiXamlUrl -OutFile $workingDirectory\$microsoftUiXamlOutName -ErrorAction Stop
            Write-Host "Microsoft UI XAML downloaded successfully."
        } catch {
            Write-Error "Failed to download Microsoft UI XAML: $_"
            throw
        }

        # Expand the archive and install the pre-req
        try {
            Write-Host "Expanding Microsoft UI XAML archive: $workingDirectory\$microsoftUiXamlOutName"
            Expand-Archive -LiteralPath "$workingDirectory\$microsoftUiXamlOutName" -DestinationPath "$workingDirectory" -Force -ErrorAction Stop
            Write-Host "Removing Microsoft UI XAML archive: $workingDirectory\$microsoftUiXamlOutName"
            Remove-Item -LiteralPath "$workingDirectory\$microsoftUiXamlOutName" -Confirm:$false -Force -ErrorAction Stop
            Write-Host "Microsoft UI XAML archive expanded and removed successfully."
        } catch {
            Write-Error "Failed to expand or remove Microsoft UI XAML archive: $_"
            throw
        }

        # Find the file with the msixbundle file, and execute it. It will select the correct system architecture to install, no need for messy WMI calls
        try {
            Write-Host "Finding Microsoft UI XAML msixbundle in $workingDirectory"
            $microsoftUiXamlMsixbundle = Get-ChildItem -Path $workingDirectory -Filter $microsoftUiXamlFileExtensionToInstall -Recurse -File | Select-Object -First 1
            Write-Host "Installing Microsoft UI XAML msixbundle from $microsoftUiXamlMsixbundle.FullName"
            Add-AppxPackage -Path $microsoftUiXamlMsixbundle.FullName -ErrorAction Stop
            Write-Host "Microsoft UI XAML msixbundle installed successfully."
        } catch {
            Write-Error "Failed to install Microsoft UI XAML msixbundle: $_"
            throw
        }

        # Download Terminal
        try {
            Write-Host "Downloading Windows Terminal from $terminalPackageUrl"
            Invoke-WebRequest -Uri $terminalPackageUrl -outfile $workingDirectory\$terminalPackageOutName -ErrorAction Stop
            Write-Host "Windows Terminal downloaded successfully."
        } catch {
            Write-Error "Failed to download Windows Terminal package: $_"
            throw
        }

        # Install Terminal
        try {
            Write-Host "Installing Windows Terminal from $workingDirectory\$terminalPackageOutName"
            Add-AppxPackage -Path "$workingDirectory\$terminalPackageOutName" -ErrorAction Stop
            Write-Host "Windows Terminal installed successfully."
        } catch {
            Write-Error "Failed to install Windows Terminal: $_"
            throw
            }
        } catch {
            Write-Host "Failed to install Windows Terminal: $_"
        } finally {
            # Ensure cleanup of temporary files
            if (Test-Path "$workingDirectory\$vcLibrariesOutName") {
                Remove-Item -LiteralPath "$workingDirectory\$vcLibrariesOutName" -Confirm:$false -Force
            }
            if (Test-Path "$workingDirectory\$microsoftUiXamlOutName") {
                Remove-Item -LiteralPath "$workingDirectory\$microsoftUiXamlOutName" -Confirm:$false -Force
            }
            if ($microsoftUiXamlMsixbundle -and (Test-Path $microsoftUiXamlMsixbundle.FullName)) {
                Remove-Item -LiteralPath $microsoftUiXamlMsixbundle.FullName -Confirm:$false -Force
            }
            if (Test-Path "$workingDirectory\$terminalPackageOutName") {
                Remove-Item -LiteralPath "$workingDirectory\$terminalPackageOutName" -Confirm:$false -Force
            }
    }
}
# Function to uninstall Windows Terminal
function Uninstall-WindowsTerminal {
    param (
        [Alias("wd", "dir")]
        [string]$workingDirectory = "..\bin"
    )

    try {
        # Check if the terminal is already installed
        $terminalPackageName = "Microsoft.WindowsTerminal"
        $installedPackage = Get-AppxPackage -Name $terminalPackageName -ErrorAction SilentlyContinue

        if ($installedPackage) {
            Write-Host "Uninstalling Windows Terminal. Version: $($installedPackage.Version)"
            Remove-AppxPackage -Package $installedPackage.PackageFullName -ErrorAction Stop
            Write-Host "Windows Terminal uninstalled successfully."
        } else {
            Write-Host "Windows Terminal is not installed."
        }
    } catch {
        Write-Error "An error occurred during the uninstallation of Windows Terminal. Error: $_"
    }
}

# Export-ModuleMember -Function * -Alias *
# New-ModuleManifest -Path .\InstallTerminalModule.psd1 -ModuleVersion "0.6.3" -Author "Jayson Knight"
# Test-ModuleManifest -Path .\InstallTerminalModule.psd1
# To update, Update-ModuleManifest -Path .\InstallTerminalModule.psd1 -ModuleVersion "0.6.3" etc