# Import Sage Container on target machine
# Usage: Run this on the destination Windows machine with Docker Desktop

param(
    [Parameter(Mandatory=$false)]
    [string]$ImagePath = ".\sage-container.tar"
)

$ErrorActionPreference = "Stop"

Write-Host "Importing Sage Container from: $ImagePath" -ForegroundColor Cyan

# Load the image from tar
& docker load -i $ImagePath

if ($LASTEXITCODE -ne 0) {
    Write-Host "Import failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`nVerifying image..." -ForegroundColor Cyan
& docker images | Select-String "sage-container"

Write-Host "`nTo run the container:" -ForegroundColor Green
Write-Host "  docker run -d --name sage sage-container:v1" -ForegroundColor Gray
Write-Host "`nTo run interactively:" -ForegroundColor Green
Write-Host "  docker run -it --name sage sage-container:v1 powershell" -ForegroundColor Gray
