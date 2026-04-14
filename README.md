# Sage Windows Container

A portable Windows container with Sage accounting software, designed for easy transfer across Windows machines on a network.

## Prerequisites

- Windows 10/11 Pro or Windows Server with Docker Desktop
- Docker Desktop configured to use **Windows containers** (not Linux containers)
- Sage installer file (`.exe` or `.msi`) for your product

## Quick Start

### 1. Prepare the Installer

Copy your Sage installer to this directory and rename it to `sage_installer.exe`

```powershell
# Example: Copy from downloads
Copy-Item "C:\Downloads\Sage300Installer.exe" ".\sage_installer.exe"
```

### 2. Build the Container

**Using Docker CLI:**
```powershell
docker build -t sage-container:v1 --build-arg SAGA_INSTALLER=sage_installer.exe .
```

**Using Docker Compose:**
```powershell
$env:SAGA_INSTALLER="sage_installer.exe"
$env:SAGETARGET="sage-300"  # or "sage-50", "sage-100", etc.
docker-compose build
docker-compose up -d
```

### 3. Transfer to Another Machine

**Export the image:**
```powershell
docker save -o sage-container.tar sage-container:v1
```

**Copy to target machine** (network share, USB, etc.):
```powershell
# Via network share
Copy-Item ".\sage-container.tar" "\\target-machine\C$\Users\admin\"
Copy-Item ".\import-sage-container.ps1" "\\target-machine\C:\Users\admin\"
```

**Import on target machine:**
```powershell
# Ensure Docker Desktop is running Windows containers
.\import-sage-container.ps1
```

### 4. Run the Container

```powershell
# Start the container
docker run -d --name sage sage-container:v1

# Check status
docker ps

# View logs
docker logs sage

# Open interactive shell (for debugging)
docker exec -it sage powershell
```

## Sage Products

This container supports multiple Sage products. Uncomment the appropriate install command in the `Dockerfile`:

| Product | Install Command (uncomment) |
|---------|---------------------------|
| Sage 300 | `Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn /norestart'` |
| Sage 50 | `Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn'` |
| Sage 100 | `Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList 'ADDLOCAL=ALL /s /v/qn'` |
| MSI-based | `Start-Process -Wait -FilePath 'msiexec.exe' -ArgumentList '/i C:\temp\sage_installer.msi /qn'` |

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SAGA_INSTALLER` | Path to installer in build context | `PLACEHOLDER` |
| `SAGETARGET` | Sage product identifier | `sage-300` |
| `SAGE_LICENSE` | License server (if applicable) | - |
| `SAGEDB_HOST` | Database host | - |
| `SAGEDB_NAME` | Database name | - |

## Docker Compose Examples

### Development/Testing
```powershell
$env:SAGA_INSTALLER="sage_installer.exe"
$env:SAGETARGET="sage-300"
docker-compose up -d
docker-compose exec sage powershell
```

### Production (with persistent data)
```yaml
services:
  sage:
    build:
      context: .
      args:
        SAGA_INSTALLER: sage_installer.exe
        SAGETARGET: sage-300
    volumes:
      - ./sage-data:/app/data
    environment:
      - SAGE_LICENSE=license-server:5070
```

## File Structure

```
sage-container/
├── Dockerfile                  # Container definition
├── docker-compose.yml          # Compose configuration
├── README.md                   # This file
├── import-sage-container.ps1   # Import script for target machine
├── build-sage-container.ps1    # Build script
├── export-sage-container.ps1    # Export script
└── sage_installer.exe          # Your Sage installer (add this)
```

## Troubleshooting

### "Cannot find path 'C:\temp\sage_installer.exe'"
Ensure you copied the installer to the build context and specified the correct path with `--build-arg SAGA_INSTALLER=`

### Docker shows Linux containers
Right-click the Docker tray icon → "Switch to Windows containers..."

### Build fails with memory error
Allocate more memory to Docker Desktop: Docker Settings → Resources → Memory (至少 4GB)

## License

This repository is for containerization purposes. You must have a valid Sage license to use this software.
