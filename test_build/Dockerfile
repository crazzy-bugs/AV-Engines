# # Use a Windows Server Core base image
# FROM mcr.microsoft.com/windows/servercore:ltsc2022

# ENV PATH="C:\Program Files\Windows Defender;%PATH%"

# WORKDIR /scripts

# # Copy the scan script
# COPY scan.ps1 /scripts/scan.ps1

# # Default entrypoint to run the scan script
# ENTRYPOINT ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "./scan.ps1"]


# Use a Windows Server Core base image with LTSC 2019
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set the path for Windows Defender
ENV PATH="C:\\Program Files\\Windows Defender;%PATH%"

# Set the working directory for the script
WORKDIR /scripts

# Copy your PowerShell script to the container
COPY scan.ps1 /scripts/scan.ps1

# Default entrypoint to run the scan script
ENTRYPOINT ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "./scan.ps1"]
