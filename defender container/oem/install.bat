@echo off

REM Install Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

REM Install Python and pip
choco install -y python pip

REM Install Python dependencies
pip install flask requests

REM Copy the Python script to a known location
copy C:\OEM\defenderscan.py C:\defenderscan.py

REM Create uploads directory
mkdir C:\uploads

REM Start the Flask application
start python C:\defenderscan.py