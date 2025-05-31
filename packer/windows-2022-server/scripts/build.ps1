Write-Output "Initializing all volumes"
Get-Disk |
    Where-Object PartitionStyle -Eq "RAW" |
    Initialize-Disk -PassThru -PartitionStyle MBR |
    New-Partition -AssignDriveLetter -UseMaximumSize |
    Format-Volume -FileSystem NTFS

Write-Output "Install Nuget"
Install-PackageProvider NuGet -Force

Write-Output "Install PSWindowsUpdate"
Install-Module PSWindowsUpdate -Force

Write-Output "Install AWSPowerShell"
Install-Module -name AWSPowerShell -Force

Write-Output "Install Security Patches"
Install-WindowsUpdate -Category Security -Install
