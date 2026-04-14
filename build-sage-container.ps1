# Build Sage Container Script
# Usage: .\build-sage-container.ps1 -SageInstallerPath "C:\path\to\SageInstaller.exe"

param(
    [Parameter(Mandatory=$false)]
    [string]$SageInstallerPath = "",

    [Parameter(Mandatory=$false)]
    [string]$ImageName = "sage-container",

    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "v1"
)

$ErrorActionPreference = "Stop"

Write-Host "Building Sage Windows Container..." -ForegroundColor Cyan

# Build arguments
$buildArgs = @()

if ($SageInstallerPath -and (Test-Path $SageInstallerPath)) {
    $buildArgs += "--build-arg", "SAGE_INSTALLER_PATH=$(Split-Path $SageInstallerPath -Leaf)"
    Write-Host "Using installer: $SageInstallerPath" -ForegroundColor Green
} else {
    $buildArgs += "--build-arg", "SAGE_INSTALLER_PATH=PLACEHOLDER"
    Write-Host "WARNING: No installer provided - building placeholder image" -ForegroundColor Yellow
}

# Copy installer to context if provided
if ($SageInstallerPath -and (Test-Path $SageInstallerPath)) {
    $installerName = Split-Path $SageInstallerPath -Leaf
    $contextDir = Split-Path $PSScriptRoot -Parent

    if ($installerName -notlike "*PLACEHOLDER*") {
        Write-Host "Copying installer to build context..."
        Copy-Item $SageInstallerPath "$contextDir\$installerName" -Force
    }
}

# Build the image
$fullImageName = "$ImageName`:$ImageTag"
$dockerArgs = @("build", "-t", $fullImageName) + $buildArgs + $contextDir

Write-Host "Running: docker $($dockerArgs -join ' ')" -ForegroundColor Gray
& docker @dockerArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful: $fullImageName" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Run container: docker run -d --name sage $fullImageName"
    Write-Host "  2. Export for transfer: .\export-sage-container.ps1 -ImageName $fullImageName"
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
