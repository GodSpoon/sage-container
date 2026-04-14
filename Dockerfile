# Windows Container with Sage
#
# BUILD:
#   docker build -t sage-container:v1 --build-arg SAGA_INSTALLER=SageInstaller.exe .
#
# Or with docker-compose:
#   docker-compose build
#   docker-compose up -d

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Build arg: path to Sage installer in build context (e.g., SageInstaller.exe)
ARG SAGA_INSTALLER

# Install prerequisites (expand as needed for your Sage version)
RUN powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force"

# Copy Sage installer into container (if provided at build time)
RUN powershell -Command \
    "if ('%SAGA_INSTALLER%' -ne '' -and '%SAGA_INSTALLER%' -ne 'PLACEHOLDER') { \
        Write-Host 'Copying installer: %SAGA_INSTALLER%'; \
        Copy-Item '%SAGA_INSTALLER%' C:\temp\sage_installer.exe -Force \
    }"

# ----------------------------------------------------------------------
# UNCOMMENT YOUR SAGE PRODUCT BELOW
# ----------------------------------------------------------------------

# SAGE 300 - Silent install
# RUN powershell -Command \
#     "if (Test-Path 'C:\temp\sage_installer.exe') { \
#         Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn /norestart'; \
#     }"

# SAGE 50 (Peachtree) - Silent install
# RUN powershell -Command \
#     "if (Test-Path 'C:\temp\sage_installer.exe') { \
#         Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn'; \
#     }"

# SAGE 100 - Silent install
# RUN powershell -Command \
#     "if (Test-Path 'C:\temp\sage_installer.exe') { \
#         Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList 'ADDLOCAL=ALL /s /v/qn'; \
#     }"

# GENERIC: Just validate installer exists (remove in production)
RUN powershell -Command \
    "if (Test-Path 'C:\temp\sage_installer.exe') { \
        Write-Host 'Sage installer present - uncomment install command in Dockerfile'; \
        Write-Host 'Installer: ' + (Get-Item 'C:\temp\sage_installer.exe').Name; \
    } else { \
        Write-Host 'WARNING: No Sage installer provided. Container built as placeholder.'; \
    }"

# Clean up
RUN powershell -Command \
    "if (Test-Path 'C:\temp\sage_installer.exe') { Remove-Item 'C:\temp\sage_installer.exe' -Force }"

EXPOSE 8080

CMD ["powershell", "Write-Host 'Sage container ready'"]
