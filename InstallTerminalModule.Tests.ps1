# To invoke this script, you can use the following command:
# Invoke-Pester -Path "$PSScriptRoot\InstallTerminalModule.Tests.ps1"



# Import the Pester module
Import-Module Pester

# Get the directory of the current script
$scriptDirectory = $PSScriptRoot
$modulePath = Join-Path -Path $scriptDirectory -ChildPath "InstallTerminalModule.psm1"
$scriptPath = Join-Path -Path $scriptDirectory -ChildPath "install-terminal.ps1"

# Check if the module exists
if (-not (Test-Path -Path $modulePath)) {
    Write-Host "The module InstallTerminalModule.psm1 does not exist in the script directory: $scriptDirectory"
    exit 1
}

# Import the module to be tested
Import-Module -Name $modulePath

# Describe block for the Get-LatestReleaseVersion function
Describe 'Get-LatestReleaseVersion' {
    It 'Should return a version string' {
        $repo = 'microsoft/terminal'
        $version = Get-LatestReleaseVersion -repo $repo
        $version | Should -Not -BeNullOrEmpty
        $version | Should -Match '^\d+\.\d+\.\d+$'
    }
}

# Describe block for the Test-Url function
Describe 'Test-Url' {
    It 'Should return true for a valid URL' {
        $url = 'https://github.com'
        $result = Test-Url -url $url
        $result | Should -Be $true
    }

    It 'Should return false for an invalid URL' {
        $url = 'https://invalid-url-for-testing.com'
        $result = Test-Url -url $url
        $result | Should -Be $false
    }
}

# Describe block for the Install-WindowsTerminal function
Describe 'Install-WindowsTerminal' {
    Mock Get-LatestReleaseVersion { return '1.21.2701.0' }
    Mock Test-Url { return $true }
    Mock Invoke-WebRequest {}
    Mock Add-AppxPackage {}
    Mock Expand-Archive {}
    Mock Remove-Item {}
    Mock Get-ChildItem { return @{ FullName = 'C:\Path\To\MockFile.msixbundle' } }

    It 'Should install Windows Terminal' {
        $workingDirectory = 'C:\Path\To\WorkingDirectory'
        Install-WindowsTerminal -repo 'microsoft/terminal' -workingDirectory $workingDirectory

        # Verify that the mocks were called
        Assert-MockCalled Get-LatestReleaseVersion -Exactly 1
        Assert-MockCalled Test-Url -Exactly 3
        Assert-MockCalled Invoke-WebRequest -Exactly 3
        Assert-MockCalled Add-AppxPackage -Exactly 3
        Assert-MockCalled Expand-Archive -Exactly 1
        Assert-MockCalled Remove-Item -Exactly 1
        Assert-MockCalled Get-ChildItem -Exactly 1
    }
}

# Describe block for the install-terminal.ps1 script
Describe 'install-terminal.ps1' {
    Mock Import-Module {}
    Mock Install-WindowsTerminal {}

    It 'Should check for the module and import it' {
        # Create a temporary script to test
        $tempScript = @"
param (
    [string]`$repo = "microsoft/terminal",
    [string]`$workingDirectory
)

# Get the directory of the current script
`$scriptDirectory = `$PSScriptRoot
`$modulePath = Join-Path -Path `$scriptDirectory -ChildPath "InstallTerminalModule.psm1"

# Check if the module exists
if (-not (Test-Path -Path `$modulePath)) {
    Write-Host "The module InstallTerminalModule.psm1 does not exist in the script directory: `$scriptDirectory"
    exit 1
}

# Import the module
Import-Module -Name `$modulePath

# Prompt user for the working directory if not provided
if (-not `$workingDirectory) {
    `$workingDirectory = Read-Host -Prompt "Enter the working directory"
}

# Install Windows Terminal
Install-WindowsTerminal -repo `$repo -workingDirectory `$workingDirectory
"@

        $tempScriptPath = Join-Path -Path $scriptDirectory -ChildPath "temp-install-terminal.ps1"
        Set-Content -Path $tempScriptPath -Value $tempScript

        # Run the temporary script
        . $tempScriptPath -repo "microsoft/terminal" -workingDirectory "C:\Path\To\WorkingDirectory"

        # Verify that the mocks were called
        Assert-MockCalled Import-Module -Exactly 1
        Assert-MockCalled Install-WindowsTerminal -Exactly 1

        # Clean up
        Remove-Item -Path $tempScriptPath -Force
    }
}