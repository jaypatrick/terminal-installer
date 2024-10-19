# Define variables
$workingDirectory = (Get-Location).Path
$binDirectory = Join-Path -Path $workingDirectory -ChildPath "bin"
$terminalPackagePath = Join-Path -Path $binDirectory -ChildPath "Microsoft.WindowsTerminal_1.10.2383.0.msixbundle"
<#
.SYNOPSIS
    Pester tests for the Install-WindowsTerminal function.

.DESCRIPTION
    This test script uses Pester to validate the functionality of the Install-WindowsTerminal function.
    It sets up the necessary environment, mocks external dependencies, and verifies that the function behaves as expected.

.SETUP
    BeforeAll
        Ensures the working directory exists.

.CLEANUP
    AfterAll
        Removes the bin directory.

.TESTCASES
    It "should create the bin directory if it does not exist"
        Verifies that the bin directory is created if it does not exist.

    It "should download the terminal package"
        Verifies that the terminal package is downloaded to the correct path.

    It "should add the app package"
        Verifies that the Add-AppxPackage function is called with the correct parameters.
#>
# Ensure the module is imported
Import-Module -Name "$PSScriptRoot\..\InstallTerminalModule.psm1"

Describe "Install-WindowsTerminal" {
    BeforeAll {
        # Setup: Ensure the working directory exists
        if (-not (Test-Path -Path $workingDirectory)) {
            New-Item -Path $workingDirectory -ItemType Directory | Out-Null
        }
    }

    AfterAll {
        # Cleanup: Remove the bin directory
        Remove-Item -Path $binDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }

    It "should create the bin directory if it does not exist" {
        Remove-Item -Path $binDirectory -Recurse -Force -ErrorAction SilentlyContinue

        Install-WindowsTerminal -workingDirectory $workingDirectory

        Test-Path -Path $binDirectory | Should -Be $true
    }

    It "should download the terminal package" {
        Remove-Item -Path $terminalPackagePath -Force -ErrorAction SilentlyContinue

        Install-WindowsTerminal -workingDirectory $workingDirectory

        Test-Path -Path $terminalPackagePath | Should -Be $true
    }

    It "should add the app package" {
        Mock Add-AppxPackage {
            param ($Path)
            $Path | Should -Be $terminalPackagePath
        }

        Install-WindowsTerminal -workingDirectory $workingDirectory
    }

    It "should call Get-LatestReleaseVersion with correct parameters" {
        Mock Get-LatestReleaseVersion {
            param ($repo)
            $repo | Should -Be "microsoft/terminal"
            return "1.21.2701.0"
        }

        Install-WindowsTerminal -workingDirectory $workingDirectory
    }
}