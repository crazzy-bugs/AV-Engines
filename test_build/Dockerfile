# Use a Windows base image
FROM mcr.microsoft.com/windows:ltsc2022

# Set environment variables for Defender CLI
ENV PATH="C:\Program Files\Windows Defender;%PATH%"

# Create a directory for scripts
WORKDIR /scripts

# Copy the scan script
COPY scan.ps1 /scripts/scan.ps1

# Default entrypoint to run the scan script
ENTRYPOINT ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "./scan.ps1"]
