# Sage Windows Container

A portable Windows container with Sage accounting software, designed for easy transfer across Windows machines on a network.

## Prerequisites

- Windows 10/11 Pro or Windows Server with Docker Desktop
- Docker Desktop configured to use **Windows containers** (right-click tray icon → Switch to Windows containers)
- Sage installer file (`.exe` or `.msi`) for your product

## Quick Start

### 1. Switch to Windows Containers

Right-click the Docker tray icon → **Switch to Windows containers...**

### 2. Get a Sage Installer

Download or obtain your Sage installer (.exe or .msi). Common products:
- [Sage 300](https://www.sage.com/products/sage-300/)
- [Sage 50](https://www.sage.com/products/sage-50/)
- [Sage 100](https://www.sage.com/products/sage-100/)

### 3. Build the Container

Place your Sage installer in this directory, then build:

```powershell
# Using Docker CLI
docker build -t sage-container:v1 --build-arg SAGA_INSTALLER=SageInstaller.exe .

# Using Docker Compose
$env:SAGA_INSTALLER = "SageInstaller.exe"
docker-compose build
docker-compose up -d
```

### 4. Run the Container

```powershell
# Start
docker run -d --name sage sage-container:v1

# Check status
docker ps

# View logs
docker logs sage

# Open shell
docker exec -it sage powershell
```

## Transferring to Another Machine

### Export the Built Image

On the source machine:
```powershell
docker save -o sage-container.tar sage-container:v1
```

### Transfer Files

Copy these to the target machine:
- `sage-container.tar` (the exported image)
- `import-sage-container.ps1` (import script)

### Import on Target Machine

On the target machine (ensure Docker Desktop is running Windows containers):
```powershell
.\import-sage-container.ps1 -ImagePath ".\sage-container.tar"
```

Then run:
```powershell
docker run -d --name sage sage-container:v1
```

## Sage Products

Uncomment the install command for your product in the `Dockerfile`:

| Product | Install Command |
|---------|-----------------|
| Sage 300 | `Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn /norestart'` |
| Sage 50 | `Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn'` |
| Sage 100 | `Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList 'ADDLOCAL=ALL /s /v/qn'` |
| MSI | `Start-Process -Wait -FilePath 'msiexec.exe' -ArgumentList '/i C:\temp\sage_installer.msi /qn'` |

## Docker Compose Examples

### Basic
```powershell
$env:SAGA_INSTALLER = "Sage300Installer.exe"
docker-compose build
docker-compose up -d
```

### With Data Persistence
```yaml
services:
  sage:
    build:
      context: .
      args:
        SAGA_INSTALLER: SageInstaller.exe
    volumes:
      - ./sage-data:/app/data
```

### With Environment Variables
```powershell
$env:SAGE_LICENSE = "license-server:5070"
$env:SAGEDB_HOST = "db-server"
docker-compose up -d
```

## File Structure

```
sage-container/
├── Dockerfile                  # Container definition
├── docker-compose.yml          # Compose configuration
├── README.md                   # This file
├── .gitignore                  # Git ignore
├── import-sage-container.ps1   # Import script for target machine
├── build-sage-container.ps1    # Build helper script
├── export-sage-container.ps1   # Export script
└── SageInstaller.exe           # Your Sage installer (add this)
```

## Troubleshooting

### "Switch to Windows containers" missing
Ensure Docker Desktop is installed and running. The option appears in the tray menu.

### Build fails - installer not found
Ensure the installer filename matches exactly what you pass to `--build-arg SAGA_INSTALLER=`

### Container exits immediately
Check logs: `docker logs sage`. The container needs a foreground process or the `tty: true` setting in compose.

## License

This repository is for containerization purposes. You must have a valid Sage license to use their software.
