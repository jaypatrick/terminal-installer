# File: ..\tests\InstallTerminal.Tests.ps1

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

# Invocation: Invoke-Pester -Script ".\tests\InstallTerminal.Tests.ps1"