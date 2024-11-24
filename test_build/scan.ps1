# Define the path to scan, passed via an environment variable or a default fallback
$scanPath = $env:SCAN_PATH -or "C:\scans"

# Ensure the scan path exists
if (-Not (Test-Path $scanPath)) {
    Write-Host "Error: Path to scan does not exist: $scanPath"
    exit 1
}

# Perform the scan using Windows Defender CLI
Write-Host "Starting scan for path: $scanPath"
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 3 -File $scanPath -DisableRemediation | Tee-Object -Variable output

# Output results to console
Write-Host "`nScan Results:`n$output"

# Check if any threats were detected
if ($output -match "Threat") {
    Write-Host "Scan detected threats:"
    $output
    exit 1
} else {
    Write-Host "Scan completed successfully. No threats found."
    exit 0
}
