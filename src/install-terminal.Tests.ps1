# File: ..\tests\InstallTerminal.Tests.ps1

<#
.SYNOPSIS
    Pester tests for the install-terminal.ps1 script.

.DESCRIPTION
    This test script uses Pester to validate the functionality of the install-terminal.ps1 script.
    It sets up the necessary environment, mocks external dependencies, and verifies that the script behaves as expected.

.SETUP
    BeforeAll
        Ensures the working directory exists.

.CLEANUP
    AfterAll
        Removes the bin directory.

.TESTCASES
    It "should check if the module exists"
        Verifies that the script checks for the existence of the module.

    It "should exit if the module does not exist"
        Verifies that the script exits if the module does not exist.

    It "should import the module"
        Verifies that the script imports the module.

    It "should prompt for the working directory if not provided"
        Verifies that the script prompts for the working directory if it is not provided.

    It "should call Install-WindowsTerminal with correct parameters"
        Verifies that the script calls Install-WindowsTerminal with the correct parameters.
#>

# Import the module to be tested
Import-Module -Name "$PSScriptRoot\..\InstallTerminalModule.psm1"

Describe "install-terminal.ps1" {
    $scriptPath = "$PSScriptRoot\..\install-terminal.ps1"
    $modulePath = "$PSScriptRoot\..\InstallTerminalModule.psm1"
    $repo = "microsoft/terminal"
    $workingDirectory = "C:\Test\WorkingDirectory"

    BeforeAll {
        # Setup: Ensure the working directory exists
        if (-not (Test-Path -Path $workingDirectory)) {
            New-Item -Path $workingDirectory -ItemType Directory | Out-Null
        }
    }

    AfterAll {
        # Cleanup: Remove the working directory
        Remove-Item -Path $workingDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }

    It "should check if the module exists" {
        Mock Test-Path { return $true }
        Mock Import-Module
        Mock Install-WindowsTerminal

        . $scriptPath -repo $repo -workingDirectory $workingDirectory

        Assert-MockCalled Test-Path -Exactly 1 -Scope It
    }

    It "should exit if the module does not exist" {
        Mock Test-Path { return $false }
        Mock Import-Module
        Mock Install-WindowsTerminal

        $result = . $scriptPath -repo $repo -workingDirectory $workingDirectory

        $result | Should -BeNullOrEmpty
    }

    It "should import the module" {
        Mock Test-Path { return $true }
        Mock Import-Module
        Mock Install-WindowsTerminal

        . $scriptPath -repo $repo -workingDirectory $workingDirectory

        Assert-MockCalled Import-Module -Exactly 1 -Scope It
    }

    It "should prompt for the working directory if not provided" {
        Mock Test-Path { return $true }
        Mock Import-Module
        Mock Install-WindowsTerminal
        Mock Read-Host { return $workingDirectory }

        . $scriptPath -repo $repo

        Assert-MockCalled Read-Host -Exactly 1 -Scope It
    }

    It "should call Install-WindowsTerminal with correct parameters" {
        Mock Test-Path { return $true }
        Mock Import-Module
        Mock Install-WindowsTerminal {
            param ($repo, $workingDirectory)
            $repo | Should -Be "microsoft/terminal"
            $workingDirectory | Should -Be "C:\Test\WorkingDirectory"
        }

        . $scriptPath -repo $repo -workingDirectory $workingDirectory
    }
}