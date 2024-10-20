Param (
    [ValidateNotNullOrEmpty()][version]$pesterVersion
)

try {
    #Install Pester
    [version]$currentPesterVersion = (Get-Module -Name Pester -ListAvailable | Select-Object -First 1).Version
    if ($currentPesterVersion -notlike "$pesterVersion*") {
        Write-Host "Installing Pester..."
        Install-Module -Name Pester -RequiredVersion $pesterVersion -Force -ErrorAction Stop
    }
    Write-Host "Using Pester version $((Get-Module -Name Pester -ListAvailable | Select-Object -First 1).Version)"

    #Set Root Location
    $rootFolder = Split-Path $PSScriptRoot -Parent
    Set-Location $rootFolder

    #Create Pester configuration.
    $pesterConfiguration = @{
        Run = @{
            Path = @("$rootFolder\Interfaces")
        }
        Should = @{
            ErrorAction = 'Continue'
        }
        CodeCoverage = @{
            OutputFormat = 'JaCoCo'
            OutputEncoding = 'UTF8'
            OutputPath = "$rootFolder\Pester-Coverage.xml"
            Enabled = $true
        }
        TestResult = @{
            OutputPath = "$rootFolder\Pester-Test.xml"
            OutputFormat = 'NUnitXml'
            OutputEncoding = 'UTF8'
            Enabled = $true
        }
    }

    #Invoke pester with the configuration hashtable
    $config = New-PesterConfiguration -Hashtable $pesterConfiguration
    Invoke-Pester -Configuration $config

    #Hacking the Codecoverage file and add the Interfaces path.
    #This is needed because $pesterConfiguration.Run.Path is set to the Interfaces folder but the running folder is not
    #Normally we would use $pesterConfiguration.Run.ExcludePath however this function does not work since Pester 5.x
    [xml]$pesterCoverageOut = get-content -path "$rootFolder\Pester-Coverage.xml"
    foreach ($classNode in $pesterCoverageOut.SelectNodes("//class")) {
        $classNode.sourcefilename = "Interfaces/$($classNode.sourcefilename)"
    }
    foreach ($sourceFileNode in $pesterCoverageOut.SelectNodes("//sourcefile")) {
        $sourceFileNode.name = "Interfaces/$($sourceFileNode.name)"
    }
    $pesterCoverageOut.Save("$rootFolder\Pester-Coverage.xml")
} 
catch {
    Write-Host "##vso[task.logissue type=error]An Error occurred`: $($_)"
    Write-Host "##vso[task.complete result=Failed;]Script failed"
}