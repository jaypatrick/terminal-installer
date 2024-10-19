<#
.SYNOPSIS
    Pester tests for the Install-WindowsTerminal function.

.DESCRIPTION
    This test script uses Pester to validate the functionality of the Install-WindowsTerminal function.
    It mocks external dependencies and verifies that the function behaves as expected.

.MOCK
    Get-LatestReleaseVersion
        Mocks the function to return a fixed version string "1.0.0".

    Test-Path
        Mocks the function to always return $false, simulating that the path does not exist.

    New-Item
        Mocks the function to return $null, simulating the creation of a new item.

    Invoke-WebRequest
        Mocks the function to return $null, simulating a web request.

    Add-AppxPackage
        Mocks the function to return $null, simulating the addition of an app package.

.TESTCASES
    It "Calls Get-LatestReleaseVersion with the correct parameters"
        Verifies that Get-LatestReleaseVersion is called exactly once with the correct parameters.

    It "Creates the bin directory if it does not exist"
        Verifies that New-Item is called exactly once to create the bin directory if it does not exist.

    It "Downloads the terminal package to the correct path"
        Verifies that Invoke-WebRequest is called to download the terminal package to the correct path.
#>
Import-Module -Name "$PSScriptRoot\..\src\InstallTerminalModule.psm1"

Describe "Install-WindowsTerminal" {
    Mock Get-LatestReleaseVersion {
        return "1.0.0"
    }

    Mock Test-Path {
        return $false
    }

    Mock New-Item {
        return $null
    }

    Mock Invoke-WebRequest {
        return $null
    }

    Mock Add-AppxPackage {
        return $null
    }

    It "Calls Get-LatestReleaseVersion with the correct parameters" {
        Install-WindowsTerminal -workingDirectory "C:\Test\WorkingDirectory"
        Assert-MockCalled Get-LatestReleaseVersion -Exactly 1 -Scope It
    }

    It "Creates the bin directory if it does not exist" {
        Install-WindowsTerminal -workingDirectory "C:\Test\WorkingDirectory"
        Assert-MockCalled New-Item -Exactly 1 -Scope It -ParameterFilter { $_.ItemType -eq 'Directory' -and $_.Path -eq 'C:\Test\WorkingDirectory\.\bin' }
    }

    It "Downloads the terminal package to the correct path" {
        Install-WindowsTerminal -workingDirectory "C:\Test\WorkingDirectory"
        Assert-MockCalled Invoke-WebRequest -Exactly 1 -Scope It -ParameterFilter { $_.Uri -eq "https://github.com/microsoft/terminal/releases/download/v1.0.0/Microsoft.WindowsTerminal_1.0.0_8wekyb3d8bbwe.msixbundle" -and $_.OutFile -eq "C:\Test\WorkingDirectory\.\bin\Microsoft.WindowsTerminal_1.0.0_8wekyb3d8bbwe.msixbundle" }
    }

    It "Calls Add-AppxPackage with the correct path" {
        Install-WindowsTerminal -workingDirectory "C:\Test\WorkingDirectory"
        Assert-MockCalled Add-AppxPackage -Exactly 1 -Scope It -ParameterFilter { $_.Path -eq "C:\Test\WorkingDirectory\.\bin\Microsoft.WindowsTerminal_1.0.0_8wekyb3d8bbwe.msixbundle" }
    }
}