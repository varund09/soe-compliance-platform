# ---------------------------------------------------
# SOE Compliance Demo Script
# Generates a JSON file with basic device checks
# ---------------------------------------------------
# Trigger pipeline run

$device = $env:COMPUTERNAME
$os = (Get-CimInstance Win32_OperatingSystem).Caption

# Disk encryption status (BitLocker)
try {
    $bitlocker = Get-BitLockerVolume -MountPoint "C:" | Select-Object -ExpandProperty ProtectionStatus
    $diskEncrypted = $bitlocker -eq 1
} catch {
    $diskEncrypted = $false
}

# Antivirus status (Defender)
try {
    $avStatus = (Get-MpComputerStatus).RealTimeProtectionEnabled
    $avInstalled = $avStatus -eq $true
} catch {
    $avInstalled = $false
}

# Required application check (Notepad for demo)
try {
    $appInstalled = Get-Command "notepad.exe" -ErrorAction SilentlyContinue | ForEach-Object { $true }
    $appInstalled = [bool]$appInstalled
} catch {
    $appInstalled = $false
}

$result = @{
    DeviceName           = $device
    OSVersion            = $os
    IsDiskEncrypted      = $diskEncrypted
    IsAntivirusOn        = $avInstalled
    RequiredAppInstalled = $appInstalled
}

# Output folder and JSON file
$outputPath = "output"
if (!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

$result | ConvertTo-Json | Out-File "$outputPath/compliance_result.json"
Write-Host "Compliance check completed. Output saved: output/compliance_result.json"


