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
# Set Root Location
$rootFolder = Split-Path $PSScriptRoot -Parent
Set-Location $rootFolder

# Create Pester configuration.
$pesterConfiguration = @{
    Run = @{
        Path = @("$rootFolder\Interfaces")  # Specify the path to the interfaces folder for running tests
    }
    Should = @{
        ErrorAction = 'Continue'  # Continue on error during Should assertions
    }
    CodeCoverage = @{
        OutputFormat = 'JaCoCo'  # Set the output format for code coverage
        OutputEncoding = 'UTF8'  # Set the output encoding for code coverage
        OutputPath = "$rootFolder\Pester-Coverage.xml"  # Specify the output path for the code coverage report
        Enabled = $true  # Enable code coverage
    }
    TestResult = @{
        OutputPath = "$rootFolder\Pester-Test.xml"  # Specify the output path for the test results
        OutputFormat = 'NUnitXml'  # Set the output format for test results
        OutputEncoding = 'UTF8'  # Set the output encoding for test results
        Enabled = $true  # Enable test results output
    }
}

# Invoke Pester with the configuration hashtable
$config = New-PesterConfiguration -Hashtable $pesterConfiguration
Invoke-Pester -Configuration $config

# Check if Pester-Coverage.xml file exists
$pesterCoveragePath = "$rootFolder\Pester-Coverage.xml"
if (Test-Path -Path $pesterCoveragePath) {
    # Hacking the CodeCoverage file and add the Interfaces path.
    # This is needed because $pesterConfiguration.Run.Path is set to the Interfaces folder but the running folder is not
    # Normally we would use $pesterConfiguration.Run.ExcludePath however this function does not work since Pester 5.x
    [xml]$pesterCoverageOut = Get-Content -Path $pesterCoveragePath
    foreach ($classNode in $pesterCoverageOut.SelectNodes("//class")) {
        $classNode.sourcefilename = "Interfaces/$($classNode.sourcefilename)"
    }
    foreach ($sourceFileNode in $pesterCoverageOut.SelectNodes("//sourcefile")) {
        $sourceFileNode.name = "Interfaces/$($sourceFileNode.name)"
    }
    $pesterCoverageOut.Save($pesterCoveragePath)
} else {
    Write-Error "Pester-Coverage.xml file does not exist. Skipping modification steps."
}

# Catch any errors that occur during the script execution
catch {
    Write-Host "##vso[task.logissue type=error]An Error occurred`: $($_)"
    Write-Host "##vso[task.complete result=Failed;]Script failed"
}