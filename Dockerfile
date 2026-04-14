# Windows Container with Sage - Placeholder for installer
#
# BUILD OPTIONS:
#
# Option 1: Place installer in build context
#   COPY SageInstaller.exe . && docker build -t sage-container:v1 .
#
# Option 2: Use build arg (installer must be in build context)
#   docker build -t sage-container:v1 --build-arg SAGA_INSTALLER=SageInstaller.exe .
#
# Option 3: Interactive (for testing)
#   docker build -t sage-container:v1 .
#   docker run -it sage-container:v1 powershell

FROM mcr.microsoft.com/windows/servercore:ltsc2022

ARG SAGETARGET=sage-300
ARG SAGA_INSTALLER=PLACEHOLDER

# Copy installer if provided
RUN powershell -Command \
    "if ('%SAGA_INSTALLER%' -ne 'PLACEHOLDER') { \
        Copy-Item '%SAGA_INSTALLER%' C:\temp\sage_installer.exe -Force \
    }"

# ---------------------------------------------------------------
# Sage Installation Commands (UNCOMMENT AND CONFIGURE YOUR VERSION)
# ---------------------------------------------------------------

# SAGE 300 - Typical silent install
# RUN powershell -Command \
#     "if (Test-Path 'C:\temp\sage_installer.exe') { \
#         Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn /norestart'; \
#     }"

# SAGE 50 (Peachtree) - Typical silent install
# RUN powershell -Command \
#     "if (Test-Path 'C:\temp\sage_installer.exe') { \
#         Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList '/s /v/qn'; \
#     }"

# SAGE 100 - Typical silent install
# RUN powershell -Command \
#     "if (Test-Path 'C:\temp\sage_installer.exe') { \
#         Start-Process -Wait -FilePath 'C:\temp\sage_installer.exe' -ArgumentList 'ADDLOCAL=ALL /s /v/qn'; \
#     }"

# SAGE 300 - MSI example
# RUN powershell -Command \
#     "if (Test-Path 'C:\temp\sage_installer.msi') { \
#         Start-Process -Wait -FilePath 'msiexec.exe' -ArgumentList '/i C:\temp\sage_installer.msi /qn'; \
#     }"

# GENERIC --placeholder message (remove when adding real install)
RUN powershell -Command \
    "if (Test-Path 'C:\temp\sage_installer.exe') { \
        Write-Host 'Sage installer found - UNCOMMENT INSTALL COMMAND IN DOCKERFILE'; \
    } else { \
        Write-Host 'PLACEHOLDER IMAGE - Sage installer not provided'; \
    }"

# Clean up installer
RUN powershell -Command \
    "if (Test-Path 'C:\temp\sage_installer.exe') { Remove-Item 'C:\temp\sage_installer.exe' -Force }"

# Default startup
CMD ["powershell", "Write-Host 'Sage Container (%SAGETARGET%) ready'"]
