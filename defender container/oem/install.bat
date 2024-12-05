@echo off
REM Set variables
set "PYTHON_VERSION=3.12.0"
set "INSTALLER_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
set "INSTALLER_PATH=%USERPROFILE%\Downloads\python-%PYTHON_VERSION%-amd64.exe"

REM Download Python installer
echo Downloading Python %PYTHON_VERSION%...
bitsadmin /transfer "PythonDownload" "%INSTALLER_URL%" "%INSTALLER_PATH%"
if not exist "%INSTALLER_PATH%" (
    echo Failed to download Python installer.
    pause
    exit /b 1
)

REM Install Python silently
echo Installing Python %PYTHON_VERSION%...
"%INSTALLER_PATH%" /quiet InstallAllUsers=1 PrependPath=1 /log install.log
if %ERRORLEVEL% NEQ 0 (
    echo Python installation failed. Check install.log for details.
    pause
    exit /b 1
)

REM Verify installation
echo Verifying Python installation...
set PATH=%ProgramFiles%\Python3X;%PATH%
python --version
if %ERRORLEVEL% NEQ 0 (
    echo Python verification failed. Ensure PATH is updated.
    pause
    exit /b 1
)

REM Install Python modules
echo Installing Python modules...
python -m pip install --upgrade pip
if %ERRORLEVEL% NEQ 0 (
    echo Failed to upgrade pip.
    pause
    exit /b 1
)

python -m pip install flask requests
if %ERRORLEVEL% NEQ 0 (
    echo Failed to install Flask and requests.
    pause
    exit /b 1
) 

REM Clean up installer
echo Cleaning up installer...
del "%INSTALLER_PATH%"

echo Python and required modules installed successfully.

REM Step 1: Check Python installation
echo Checking Python installation...
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Python is not installed. Please install Python and try again.
    pause
    exit /b 1
)

REM Step 2: Create a virtual environment
echo Setting up a virtual environment...
python -m venv venv
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to create a virtual environment. Exiting.
    pause
    exit /b 1
)

REM Step 3: Activate the virtual environment
call venv\Scripts\activate
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to activate the virtual environment. Exiting.
    pause
    exit /b 1
)

REM Step 4: Install dependencies
echo Installing required Python packages...
REM pip install --upgrade pip
pip install flask >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install Flask. Exiting.
    deactivate
    pause
    exit /b 1
)
pip install requests >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install requests. Exiting.
    deactivate
    pause
    exit /b 1
)

REM Step 5: Run the Python script
echo Running the Windows Defender Python script...
python defenderScan.py
IF %ERRORLEVEL% NEQ 0 (
    echo The script encountered an error. Exiting.
    deactivate
    pause
    exit /b 1
)

REM Step 6: Clean up (optional)
echo Deactivating the virtual environment...
deactivate

echo Script completed successfully.
pause
exit /b 0

REM Copy the Python script to a known location
copy C:\OEM\defenderscan.py C:\defenderscan.py

REM Create uploads directory
mkdir C:\uploads

REM Start the Flask application
start python C:\defenderscan.py