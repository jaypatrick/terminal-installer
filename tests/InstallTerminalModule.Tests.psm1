# Import the module to be tested
Import-Module -Name "$PSScriptRoot\..\src\InstallTerminalModule.psm1"

Describe "Install-WindowsTerminal" {
    Mock Get-LatestReleaseVersion {
        return "1.10.2383.0"
    }

    Mock Invoke-WebRequest {
        return $null
    }

    Mock Add-AppxPackage {
        return $null
    }

    It "should create the bin directory if it does not exist" {
        $workingDirectory = "C:\Path\To\WorkingDirectory"
        $binDirectory = Join-Path -Path $workingDirectory -ChildPath ".\bin"

        Remove-Item -Path $binDirectory -Recurse -Force -ErrorAction SilentlyContinue

        Install-WindowsTerminal -workingDirectory $workingDirectory

        Test-Path -Path $binDirectory | Should -Be $true
    }

    It "should download the terminal package" {
        $workingDirectory = "C:\Path\To\WorkingDirectory"
        $binDirectory = Join-Path -Path $workingDirectory -ChildPath ".\bin"
        $terminalPackageOutName = "Microsoft.WindowsTerminal_1.10.2383.0_8wekyb3d8bbwe.msixbundle"
        $terminalPackagePath = Join-Path -Path $binDirectory -ChildPath $terminalPackageOutName

        Remove-Item -Path $terminalPackagePath -Force -ErrorAction SilentlyContinue

        Install-WindowsTerminal -workingDirectory $workingDirectory

        Test-Path -Path $terminalPackagePath | Should -Be $true
    }

    It "should add the app package" {
        $workingDirectory = "C:\Path\To\WorkingDirectory"
        $binDirectory = Join-Path -Path $workingDirectory -ChildPath ".\bin"
        $terminalPackageOutName = "Microsoft.WindowsTerminal_1.10.2383.0_8wekyb3d8bbwe.msixbundle"
        $terminalPackagePath = Join-Path -Path $binDirectory -ChildPath $terminalPackageOutName

        Mock Add-AppxPackage {
            param ($Path)
            $Path | Should -Be $terminalPackagePath
        }

        Install-WindowsTerminal -workingDirectory $workingDirectory
    }
}