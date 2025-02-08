# Manual Dir Based
# Define Dir Apps
# $apps = @(
#     "D:\sample\main.exe"
#     "D:\sample\main.exe",
#     "D:\sample\main.exe",
#     "D:\sample\main.exe"
# )

# Scan Dir Based
# Define the base directory
# $baseDir = "D:\Project\Farm\App\Golang\parameter-service\tmp"
# Same Folder
# $apps = Get-ChildItem -Path $baseDir -Filter "*.exe" | Sort-Object Name | Select-Object -ExpandProperty FullName

# Scan Dir Based
# Define the base directory
$baseDir = "D:\Sample"
# Multi Folder
# Define the subdirectories
$serviceDirs = @(
    "sample\path",
    "sample\path",
    "sample\path",
    "sample\path"
)

# Define executable app name
$executableName = "main.exe"

# Build the $apps array by searching for executable
$apps = foreach ($subDir in $serviceDirs) {
    # Combine path
    $fullPath = Join-Path -Path $baseDir -ChildPath $subDir
    # Look for the executable
    $exeFile = Get-ChildItem -Path $fullPath -Filter $executableName -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($exeFile) {
        $exeFile.FullName
    } else {
        Write-Warning "$executableName not found in $fullPath"
    }
}

# DEfine name services may run first
$services = @(
    "sample-service",
    "sample-service",
    "sample-service"
)

# Define Delay in Second
$delay = 90

# Log the discovered application paths
$log = "D:\sample\log.txt"
Add-Content -Path $log -Value "$(Get-Date) Discovered executables: $($apps -join ', ')"

# Begin Run App
Add-Content -Path $log -Value "$(Get-Date) Auto start app when restart"

# Run Services Need By App
foreach ($service in $services) {
    try {
        Start-Service -Name $service -ErrorAction Stop
        Add-Content -Path $log -Value "$(Get-Date) Started service-name :  $service"   
    }
    catch {
        Add-Content -Path $log -Value "$(Get-Date) Failed to start service-name : $service -$_"
    }
    Start-Sleep 2
}

Add-Content -Path $log -Value "$(Get-Date) Add delay $delay Seconds Waiting for other services start"
Start-Sleep $delay

# Run App
foreach ($app in $apps) {
    try {
        Start-Process $app -ErrorAction SilentlyContinue
    }
    catch {
        Add-Content -Path $log -Value "$(Get-Date) Failed to start app-name : $app -$_"
    }
    Start-Sleep 5
    Add-Content -Path $log -Value "$(Get-Date) Start app-name : $app"
}

# Finish
Add-Content -Path $log -Value "$(Get-Date) Finish"
