BeforeAll {
    . "..\src\InstallTerminalModule.psm1"
}

# Import the module to be tested
# Import-Module "$PSScriptRoot/../src/InstallTerminalModule.psm1"

# Describe block for Install-WindowsTerminal function
Describe "Install-WindowsTerminal" {
    # Mocking Get-LatestReleaseVersion function
    Mock -CommandName Get-LatestReleaseVersion -MockWith { return "1.0.0" }

    # Mocking Test-Url function
    Mock -CommandName Test-Url -MockWith { return $true }

    # Mocking Invoke-WebRequest function
    Mock -CommandName Invoke-WebRequest

    # Mocking Add-AppxPackage function
    Mock -CommandName Add-AppxPackage

    # Mocking Expand-Archive function
    Mock -CommandName Expand-Archive

    # Mocking Remove-Item function
    Mock -CommandName Remove-Item

    # Mocking Get-AppxPackage function
    Mock -CommandName Get-AppxPackage -MockWith { return $null }

    # Test case when Windows Terminal is not installed
    Context "When Windows Terminal is not installed" {
        It "Should download and install Windows Terminal and prerequisites" {
            $workingDirectory = "C:\Temp"

            Install-WindowsTerminal -workingDirectory $workingDirectory

            # Verify that the functions were called with expected parameters
            Should -Invoke -CommandName Get-LatestReleaseVersion -Exactly 1
            Should -Invoke -CommandName Test-Url -Exactly 3
            Should -Invoke -CommandName Invoke-WebRequest -Exactly 3
            Should -Invoke -CommandName Add-AppxPackage -Exactly 3
            Should -Invoke -CommandName Expand-Archive -Exactly 1
            Should -Invoke -CommandName Remove-Item -Exactly 1
        }
    }

    # Test case when Windows Terminal is already installed
    Context "When Windows Terminal is already installed" {
        Mock -CommandName Get-AppxPackage -MockWith { return @{ Version = "1.0.0" } }

        It "Should not attempt to install Windows Terminal" {
            $workingDirectory = "C:\Temp"

            Install-WindowsTerminal -workingDirectory $workingDirectory

            # Verify that the functions were not called
            Should -Invoke -CommandName Get-LatestReleaseVersion -Exactly 0
            Should -Invoke -CommandName Test-Url -Exactly 0
            Should -Invoke -CommandName Invoke-WebRequest -Exactly 0
            Should -Invoke -CommandName Add-AppxPackage -Exactly 0
            Should -Invoke -CommandName Expand-Archive -Exactly 0
            Should -Invoke -CommandName Remove-Item -Exactly 0
        }
    }
}
# Tests for Get-LatestReleaseVersion function
Describe "Get-LatestReleaseVersion" {
    Mock -CommandName Invoke-RestMethod -MockWith {
        return @{ tag_name = "v1.2.3" }
    }

    It "Should return the latest release version" {
        $repo = "microsoft/terminal"
        $result = Get-LatestReleaseVersion -repo $repo
        $result | Should -Be "1.2.3"
    }
}

# Tests for Test-Url function
Describe "Test-Url" {
    Context "When URL exists" {
        Mock -CommandName Invoke-WebRequest -MockWith { return $true }

        It "Should return true" {
            $url = "https://example.com"
            $result = Test-Url -url $url
            $result | Should -Be $true
        }
    }

    Context "When URL does not exist" {
        Mock -CommandName Invoke-WebRequest -MockWith { throw "404 Not Found" }

        It "Should return false" {
            $url = "https://nonexistent.com"
            $result = Test-Url -url $url
            $result | Should -Be $false
        }
    }
}

# Tests for Install-WindowsTerminal function
Describe "Install-WindowsTerminal" {
    Mock -CommandName Get-LatestReleaseVersion -MockWith { return "1.0.0" }
    Mock -CommandName Test-Url -MockWith { return $true }
    Mock -CommandName Invoke-WebRequest
    Mock -CommandName Add-AppxPackage
    Mock -CommandName Expand-Archive
    Mock -CommandName Remove-Item
    Mock -CommandName Get-AppxPackage -MockWith { return $null }

    Context "When Windows Terminal is not installed" {
        It "Should download and install Windows Terminal and prerequisites" {
            $workingDirectory = "C:\Temp"

            Install-WindowsTerminal -workingDirectory $workingDirectory

            Should -Invoke -CommandName Get-LatestReleaseVersion -Exactly 1
            Should -Invoke -CommandName Test-Url -Exactly 3
            Should -Invoke -CommandName Invoke-WebRequest -Exactly 3
            Should -Invoke -CommandName Add-AppxPackage -Exactly 3
            Should -Invoke -CommandName Expand-Archive -Exactly 1
            Should -Invoke -CommandName Remove-Item -Exactly 1
        }
    }

    Context "When Windows Terminal is already installed" {
        Mock -CommandName Get-AppxPackage -MockWith { return @{ Version = "1.0.0" } }

        It "Should not attempt to install Windows Terminal" {
            $workingDirectory = "C:\Temp"

            Install-WindowsTerminal -workingDirectory $workingDirectory

            Should -Invoke -CommandName Get-LatestReleaseVersion -Exactly 0
            Should -Invoke -CommandName Test-Url -Exactly 0
            Should -Invoke -CommandName Invoke-WebRequest -Exactly 0
            Should -Invoke -CommandName Add-AppxPackage -Exactly 0
            Should -Invoke -CommandName Expand-Archive -Exactly 0
            Should -Invoke -CommandName Remove-Item -Exactly 0
        }
    }
}