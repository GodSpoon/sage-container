# Export Sage Container for Network Transfer
# Usage: .\export-sage-container.ps1 -ImageName sage-container:v1 -OutputPath "\\network\share"

param(
    [Parameter(Mandatory=$false)]
    [string]$ImageName = "sage-container:v1",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\sage-container.tar",

    [Parameter(Mandatory=$false)]
    [switch]$LoadOnRemote
)

$ErrorActionPreference = "Stop"

Write-Host "Exporting Sage Container: $ImageName" -ForegroundColor Cyan

# Create output directory if local path
if ($OutputPath -notlike "\\*") {
    $outputDir = Split-Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
}

# Save image to tar archive
Write-Host "Saving image to: $OutputPath" -ForegroundColor Yellow
& docker save -o $OutputPath $ImageName

if ($LASTEXITCODE -ne 0) {
    Write-Host "Export failed!" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $OutputPath).Length / 1GB
Write-Host "Export complete! Size: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Green

# Generate import script content
$importScript = @"
# Import Sage Container on target machine
# Usage: Run this on the destination Windows machine with Docker

# Load the image
docker load -i .\sage-container.tar

# Verify
docker images | findstr sage-container

# Run the container
docker run -d --name sage sage-container:v1
"@

$importScriptPath = [System.IO.Path]::Combine((Split-Path $OutputPath -Parent), "import-sage-container.ps1")
Set-Content -Path $importScriptPath -Value $importScript -Encoding UTF8

Write-Host "`nTransfer to another Windows machine and run:" -ForegroundColor Cyan
Write-Host "  docker load -i sage-container.tar" -ForegroundColor Gray
Write-Host "  docker run -d --name sage sage-container:v1" -ForegroundColor Gray
Write-Host "`nImport script created: $importScriptPath" -ForegroundColor Green
