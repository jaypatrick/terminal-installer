# Import the module to be tested
Import-Module -Name "..\InstallTerminalModule.psm1"

# Unit tests for Test-OSVersion
Describe "Test-OSVersion" {
    It "Should return true for Windows Server 2016 or newer" {
        Mock Get-CimInstance { return @{ Version = "10.0.14393" } }
        $result = Test-OSVersion
        $result | Should -Be $true
    }

    It "Should return false for older versions" {
        Mock Get-CimInstance { return @{ Version = "6.3.9600" } }
        $result = Test-OSVersion
        $result | Should -Be $false
    }

    It "Should handle errors gracefully" {
        Mock Get-CimInstance { throw "Error" }
        $result = Test-OSVersion
        $result | Should -Be $false
    }
}

# Unit tests for Create-WorkingDirectory
Describe "Create-WorkingDirectory" {
    It "Should create the directory if it does not exist" {
        Mock Test-Path { return $false }
        Mock New-Item { return $null }
        { Create-WorkingDirectory -workingDirectory "C:\test\dir" } | Should -Not -Throw
    }

    It "Should not create the directory if it exists" {
        Mock Test-Path { return $true }
        { Create-WorkingDirectory -workingDirectory "C:\test\dir" } | Should -Not -Throw
    }

    It "Should handle errors gracefully" {
        Mock Test-Path { throw "Error" }
        { Create-WorkingDirectory -workingDirectory "C:\test\dir" } | Should -Throw
    }
}

# Unit tests for Get-Config
Describe "Get-Config" {
    It "Should read the configuration file correctly" {
        Mock Get-Content { return '{"terminalPackageRepo": "microsoft/terminal"}' }
        $config = Get-Config -configFilePath "path\to\config.json"
        $config.terminalPackageRepo | Should -Be "microsoft/terminal"
    }

    It "Should handle errors gracefully" {
        Mock Get-Content { throw "Error" }
        { Get-Config -configFilePath "path\to\config.json" } | Should -Throw
    }
}

# Unit tests for Get-LatestReleaseVersion
Describe "Get-LatestReleaseVersion" {
    It "Should return the latest release version" {
        Mock Invoke-RestMethod { return @{ tag_name = "v1.0.0" } }
        $version = Get-LatestReleaseVersion -repo "microsoft/terminal"
        $version | Should -Be "1.0.0"
    }

    It "Should handle errors gracefully" {
        Mock Invoke-RestMethod { throw "Error" }
        { Get-LatestReleaseVersion -repo "microsoft/terminal" } | Should -Throw
    }
}

# Unit tests for Install-WindowsTerminal
Describe "Install-WindowsTerminal" {
    It "Should install Windows Terminal" {
        Mock Test-OSVersion { return $true }
        Mock Create-WorkingDirectory { return $null }
        Mock Get-Config { return @{ terminalPackageRepo = "microsoft/terminal" } }
        Mock Get-LatestReleaseVersion { return "1.0.0" }
        Mock Invoke-WebRequest { return $null }
        Mock Add-AppxPackage { return $null }
        { Install-WindowsTerminal -workingDirectory "C:\test\dir" } | Should -Not -Throw
    }

    It "Should handle errors gracefully" {
        Mock Test-OSVersion { throw "Error" }
        { Install-WindowsTerminal -workingDirectory "C:\test\dir" } | Should -Throw
    }
}

# Unit tests for Uninstall-WindowsTerminal
Describe "Uninstall-WindowsTerminal" {
    It "Should uninstall Windows Terminal" {
        Mock Get-AppxPackage { return @{ PackageFullName = "Microsoft.WindowsTerminal" } }
        Mock Remove-AppxPackage { return $null }
        { Uninstall-WindowsTerminal -workingDirectory "C:\test\dir" } | Should -Not -Throw
    }

    It "Should handle errors gracefully" {
        Mock Get-AppxPackage { throw "Error" }
        { Uninstall-WindowsTerminal -workingDirectory "C:\test\dir" } | Should -Throw
    }
}

# Unit tests for Test-TerminalRepoUrl
Describe "Test-TerminalRepoUrl" {
    It "Should return true for a valid URL" {
        Mock Invoke-WebRequest { return $null }
        $result = Test-TerminalRepoUrl -url "https://github.com/microsoft/terminal"
        $result | Should -Be $true
    }

    It "Should return false for an invalid URL" {
        Mock Invoke-WebRequest { throw "Error" }
        $result = Test-TerminalRepoUrl -url "https://invalid.url"
        $result | Should -Be $false
    }
}

# Invoke the tests with the following command:
# Invoke-Pester -Path ".\Tests\InstallTerminalModule.Tests.ps1"